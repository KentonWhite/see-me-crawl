require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  

require 'amqp'

DataMapper.setup(:default, ENV['DATABASE_URL'])


DataMapper.auto_upgrade!

AMQP.start('amqp://lcpdyzjs:nko1XmnZfRul4Hza@gqezbdhq.heroku.srs.rabbitmq.com:21146/gqezbdhq') do |connection|
  channel    = AMQP::Channel.new(connection, :auto_recovery => true)

  channel.prefetch(1)
  
  channel.queue("com.girih.samples", :durable => true, :auto_delete => false).subscribe(:ack => true) do |metadata, payload|
    case metadata.type
    when "new_samples"
      puts "Receive message for node #{payload}"
      unless UnprocessedMessage.count(node: payload) > 0 
        node = HashtagTwitterNode.new(payload.to_i)
        node.check_hashtag
      end
    end
    
    metadata.ack
  end
  
  puts "Ready to listen to messages queue"
end