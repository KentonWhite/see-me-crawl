require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/tag_counter'

require 'amqp'

# Enable unbuffered output
STDOUT.sync = true


def process_messages(messages)
  counter = TagCounter.new
  
    puts "Processing #{messages.count} messages"
    STDOUT.flush
  
    messages.each do |m|
      counter.add(m.message_date, 'message', m.node)
      m.save!   
    end
  
    counter.each do |date, tag, nodes|
      message_count = MessageCount.first_or_new({date: date}, {count: 0})
      message_count.count += nodes.count
      message_count.save
    end
    puts "Finished processing messages"
    STDOUT.flush
  
end

def process_hashtags(hashtags)
  counter = TagCounter.new
  
  puts "Processing #{hashtags.count} hashtags"
  STDOUT.flush
  
  hashtags.each do |h|
    counter.add(h.hashtag_date, h.hashtag, h.node)
    attrs = h.attributes
    begin    
      h.save!
    rescue e
      p e.message
      puts "error creating hashtag:"   
      p h
      next
    end
  end
  
  counter.each do |date, tag, nodes|
    hashtag_count = HashtagCount.first_or_new({date: date, hashtag: tag}, {count: 0})
      hashtag_count.count += nodes.count
    begin
      hashtag_count.save
    rescue e
      p e.message
      puts "error creating hashtag_count:"
      p hashtag_count
      next
    end
  end
  puts "Finished processing hashtags"
  STDOUT.flush
end

def process_mentions(mentions)
  counter = TagCounter.new

    puts "Processing #{mentions.count} mentions"
    STDOUT.flush
  
    mentions.each do |m|
      counter.add(m.mention_date, m.mention, m.node)
      m.save!   
    end
  
    counter.each do |date, tag, nodes|
      mention_count = MentionCount.first_or_new({date: date, mention: tag}, {count: 0})
      mention_count.count += nodes.count
      mention_count.save
    end
    puts "Finished processing mentions"
    STDOUT.flush
  
end

def process_tags(tags)
  counter = TagCounter.new

    puts "Processing #{tags.count} tags"
  
    tags.each do |t|
      counter.add(t.date, t.tag, t.node)
      t.save!   
    end
  
    counter.each do |date, tag, nodes|
      tag_count = TagCount.first_or_new({date: date, tag: tag}, {count: 0})
      tag_count.count += nodes.count
      tag_count.save
    end
    puts "Finished processing tags"
  
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
        process_messages(node.messages)
        process_hashtags(node.hashtags)
        process_mentions(node.mentions)
        process_tags(node.tags)
      end
    else
      puts "Unknown message type #{metadata.type}"
    end
    
    metadata.ack
  end
  
  puts "Ready to listen to messages queue"
  STDOUT.flush
end

