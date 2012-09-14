require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  

require 'amqp'

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
        hashtags = UnprocessedHashtag.all
        process_hashtags if hashtags.count > 1000

      end
    else
      puts "Unknown message type #{metadata.type}"
    end
    
    metadata.ack
  end
  
  puts "Ready to listen to messages queue"
  STDOUT.flush
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