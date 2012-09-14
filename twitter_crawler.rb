require './lib/metropolis_hastings_markov_chain.rb'
require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/entropy.rb'

require 'bunny'

DataMapper.setup(:default, ENV['DATABASE_URL'])

DataMapper.auto_upgrade!

cftp = CoupleFromThePast.new
sample = NoConvergeSample.new
sample_size = 10
min_coupling_time = 5

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
  small_set = cft.aggregation_by_backward_coupling([previous_node], sample_size, min_coupling_time)
  samples = cftp.cftp(-1, small_set, min_coupling_time)
  samples.eac do |current_node|
    puts "Sampled #{current_node}"
    sample.save!(current_node) { |node| node.degree }
    exchange.publish(current_node.id, type: 'new_samples', key: 'com.girih.samples')
    previous_node = current_node
  end
end

puts sample.expectation_value
p sample.last

