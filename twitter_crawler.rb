require './lib/metropolis_hastings_markov_chain.rb'
require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/entropy.rb'

require 'bunny'

DataMapper.setup(:default, adapter: 'mysql', database: 'graph', user: 'root')

DataMapper.setup(:local, adapter: 'mysql', database: 'sample', user: 'root')

DataMapper.auto_upgrade!

DataMapper.repository(:local) { Sample.auto_upgrade! }
DataMapper.repository(:local) { Hashtag.auto_upgrade! }
DataMapper.repository(:local) { Mention.auto_upgrade! }
DataMapper.repository(:local) { Message.auto_upgrade! }
DataMapper.repository(:local) { UnprocessedHashtag.auto_upgrade! }
DataMapper.repository(:local) { UnprocessedMention.auto_upgrade! }
DataMapper.repository(:local) { UnprocessedMessage.auto_upgrade! }

markov_chain = MetropolisHastingsMarkovChain.new
sample = NoConvergeSample.new

ampq = Bunny.new('amqp://lcpdyzjs:nko1XmnZfRul4Hza@gqezbdhq.heroku.srs.rabbitmq.com:21146/gqezbdhq')
ampq.start

exchange = ampq.exchange("")

if sample.last_node
  previous_node = HashtagTwitterNode.new(sample.last_node)
else
  previous_node = HashtagTwitterNode.new(16450138)
end  
  previous_node.crawl!

while true
  begin
    current_node = markov_chain.next(previous_node)
  rescue => e
    p e.message
    p previous_node
    raise e
  end
  p current_node.id
  current_node.crawl! 
  sample.save!(current_node) { |node| 0 }
  puts "Sending message for node #{current_node.id}"
  exchange.publish(current_node.id, type: 'new_samples', key: 'com.girih.samples')
  previous_node = current_node
end

puts sample.expectation_value
p sample.last

