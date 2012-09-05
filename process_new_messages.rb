require './lib/sample.rb'
require './lib/tag_counter'
require 'logger'
require 'dm-aggregates'
log = Logger.new(STDOUT)
log.level = Logger::INFO

DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
DataMapper.auto_upgrade!

log.info("Start message processing queue")
  
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
      hashtag_count = HashtagCount.first_or_new(date: date, hashtag: tag)
      hashtag_count.count = nodes.count
      hashtag_mh_count = HashtagMhCount.first_or_new(date: date, hashtag: tag)
      hashtag_mh_count.count = Sample.count(node: nodes.to_a)
      hashtag_count.save
      hashtag_mh_count.save
    end
  end
    
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
      mention_count = MentionCount.first_or_new(date: date, mention: tag)
      mention_count.count = nodes.count
      mention_mh_count = MentionMhCount.first_or_new(date: date, mention: tag)
      mention_mh_count.count = Sample.count(node: nodes.to_a)
      mention_count.save
      mention_mh_count.save
    end
  end
      
  messages = UnprocessedMessage.all
  
  if messages.count > 1000 then
    log.info("Processing #{messages.count} messages")
  
    messages.each do |m|
      counter.add(m.message_date, 'message', m.node)
      attrs = m.attributes
      attrs.delete(:id)
      Message.create(attrs)    
      m.destroy
    end
  
    counter.each do |date, tag, nodes|
      message_count = MessageCount.first_or_new(date: date)
      message_count.count = nodes.count
      message_mh_count = MentionMhCount.first_or_new(date: date)
      message_mh_count.count = Sample.count(node: nodes.to_a)
      message_count.save
      message_mh_count.save
    end
  end
  
  sleep 10
end
  
log.info("Ending message processing queue")
 