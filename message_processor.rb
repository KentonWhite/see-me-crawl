require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/tag_counter'

require 'amqp'

def process_messages(messages)
  counter = TagCounter.new
  
  if messages.count > 1000 then
    puts "Processing #{messages.count} messages"
    STDOUT.flush
  
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
      message_mh_count = MessageMhCount.first_or_new({date: date}, {count: 0})
      message_mh_count.count += Sample.count(node: nodes.to_a)
      message_count.save
      message_mh_count.save
    end
    puts "Finished processing messages"
    STDOUT.flush
  end
  
end

def process_hashtags(hashtags)
  counter = TagCounter.new
  
  puts "Processing #{hashtags.count} hashtags"
  STDOUT.flush
  
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
  puts "Finished processing hashtags"
  STDOUT.flush
end

def process_mentions(mentions)
  counter = TagCounter.new

  if mentions.count > 1000 then
    puts "Processing #{mentions.count} mentions"
    STDOUT.flush
  
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
    puts "Finished processing mentions"
    STDOUT.flush
  end
  
end

DataMapper.setup(:default, ENV['DATABASE_URL'])


DataMapper.auto_upgrade!

AMQP.start('amqp://lcpdyzjs:nko1XmnZfRul4Hza@gqezbdhq.heroku.srs.rabbitmq.com:21146/gqezbdhq') do |connection|
  channel    = AMQP::Channel.new(connection, :auto_recovery => true)

  channel.prefetch(1)
  
  channel.queue("com.girih.samples", :durable => true, :auto_delete => false).subscribe(:ack => true) do |metadata, node|
    case metadata.type
    when "new_samples"
      puts "Process new node #{node}"
      STDOUT.flush
      unless UnprocessedMessage.count(node: node) > 0 
        node = HashtagTwitterNode.new(node.to_i)
        node.check_hashtag
        messages = UnprocessedMessage.all
        process_messages(messages) if messages.count > 1000
        hashtags = UnprocessedHashtag.all
        process_hashtags(hashtags) if hashtags.count > 1000
        mentions = UnprocessedMention.all
        process_mentions(mentions) if mentions.count > 1000

      end
    else
      puts "Unknown message type #{metadata.type}"
    end
    
    metadata.ack
  end
  
  puts "Ready to listen to messages queue"
  STDOUT.flush
end

