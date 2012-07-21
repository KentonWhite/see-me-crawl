require './lib/metropolis_hastings_markov_chain.rb'
require './lib/no_converge_sample.rb'
require './lib/hashtag_twitter_node.rb'  
require './lib/entropy.rb'

DataMapper.setup(:default, adapter: 'mysql', database: 'graph', user: 'root')

DataMapper.setup(:local, adapter: 'mysql', database: 'sample', user: 'root')

DataMapper.auto_upgrade!

DataMapper.repository(:local) { Sample.auto_upgrade! }

markov_chain = MetropolisHastingsMarkovChain.new
sample = NoConvergeSample.new

calculator = Entropy.new
if sample.last_node
  previous_node = HashtagTwitterNode.new(sample.last_node)
else
  previous_node = HashtagTwitterNode.new(16450138)
  previous_node.crawl!
end  

until sample.converged? 
  begin
    current_node = markov_chain.next(previous_node)
  rescue => e
    p e.message
    p previous_node
    raise e
  end
  p current_node.id
  current_node.crawl! 
  sample.save!(current_node) { |node| current_node.hashtag? }
  previous_node = current_node
end

puts sample.expectation_value
p sample.last