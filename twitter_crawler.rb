require './lib/metropolis_hastings_markov_chain.rb'
require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/entropy.rb'

require 'bunny'

DataMapper.setup(ENV['DATABASE_URL'])

DataMapper.auto_upgrade!

markov_chain = MetropolisHastingsMarkovChain.new
sample = NoConvergeSample.new

ampq = Bunny.new(ENV['RABBITMQ_URL'])
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

