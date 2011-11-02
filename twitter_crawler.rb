require './lib/metropolis_hastings_markov_chain.rb'
require './lib/z_sample.rb'
require './lib/twitter_node.rb'  

DataMapper.setup(:local, adapter: 'sqlite3', database: 'sample.db')

DataMapper.setup(:default, 
  adapter:    'simpledb',
  access_key: 'AKIAJOOPW5QN4DZJG2BA',
  secret_key: 'xPedqv6zdtPtxsM/PtxiB6kXrgNb5C9Y9R19JvR1',
  domain:     'gertrude-stein-tw'
)

DataMapper.auto_upgrade!

markov_chain = MetropolisHastingsMarkovChain.new
sample = ZSample.new
previous_node = TwitterNode.new(sample.last_node)

until sample.converged?
  current_node = TwitterNode.new(markov_chain.next(previous_node))
  current_node.populate!
  current_node.save!
  sample.save!(current_node) { |node| node.degree }
  previous_node = current_node
end

puts sample.expectation_value