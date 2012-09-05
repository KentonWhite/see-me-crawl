require './lib/sample.rb'
require './lib/tag_counter'
require 'logger'
require 'dm-aggregates'
log = Logger.new(STDOUT)
log.level = Logger::INFO

DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
DataMapper.auto_upgrade!

log.info("Start mention processing queue")
  
while(true) do
  
  counter = TagCounter.new
  
  
    
  mentions = UnprocessedMention.all
  
  if mentions.count > 1000 then
    log.info("Processing #{mentions.count} mentions")
  
    mentions.each do |m|
      counter.add(m.mention_date, m.mention, m.node)
      attrs = m.attributes
      attrs.delete(:id)
      Mention.create(attrs)    
      m.destroy
    end
  
    counter.each do |date, tag, nodes|
      mention_count = MentionCount.first_or_new({date: date, mention: tag}, {count: 0})
      mention_count.count += nodes.count
      mention_mh_count = MentionMhCount.first_or_new({date: date, mention: tag}, {count: 0})
      mention_mh_count.count += Sample.count(node: nodes.to_a)
      mention_count.save
      mention_mh_count.save
    end
    log.info("Finished processing mentions")
  end
      
  sleep 1
end
  
log.info("Ending mention processing queue")
 