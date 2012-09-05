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
      message_count = MessageCount.first_or_new({date: date}, {count: 0})
      message_count.count += nodes.count
      message_mh_count = MentionMhCount.first_or_new({date: date}, {count: 0})
      message_mh_count.count += Sample.count(node: nodes.to_a)
      message_count.save
      message_mh_count.save
    end
  end
  sleep 1
end
  
log.info("Ending message processing queue")
 