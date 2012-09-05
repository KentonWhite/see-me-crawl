require './lib/sample.rb'
require './lib/tag_counter'
require 'logger'
require 'dm-aggregates'
log = Logger.new(STDOUT)
log.level = Logger::INFO

DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
DataMapper.auto_upgrade!

log.info("Start hashtag processing queue")
  
while(true) do
  
  counter = TagCounter.new
  
  
  hashtags = UnprocessedHashtag.all
  if hashtags.count > 1000 then
    log.info("Processing #{hashtags.count} hashtags")
  
    hashtags.each do |h|
      counter.add(h.hashtag_date, h.hashtag, h.node)
      attrs = h.attributes
      attrs.delete(:id)
      Hashtag.create(attrs)    
      h.destroy
    end
  
    counter.each do |date, tag, nodes|
      hashtag_count = HashtagCount.first_or_new({date: date, hashtag: tag}, {count: 0})
      hashtag_count.count += nodes.count
      hashtag_mh_count = HashtagMhCount.first_or_new({date: date, hashtag: tag}, {count: 0})
      hashtag_mh_count.count += Sample.count(node: nodes.to_a)
      hashtag_count.save
      hashtag_mh_count.save
    end
  end
    
  sleep 1
end
  
log.info("Ending hashtag processing queue")
 