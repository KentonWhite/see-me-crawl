require './lib/metropolis_hastings_markov_chain.rb'
require './lib/z_sample.rb'
require './lib/twitter_node.rb'  

# DataMapper.setup(:default, adapter: 'sqlite3', database: 'graph.db')

DataMapper.setup(:default, 
  adapter:    'simpledb',
  access_key: 'AKIAJOOPW5QN4DZJG2BA',
  secret_key: 'xPedqv6zdtPtxsM/PtxiB6kXrgNb5C9Y9R19JvR1',
  domain:     'gertrude-stein-tw'
)
DataMapper.setup(:local, adapter: 'sqlite3', database: 'sample.db')

DataMapper.auto_upgrade!

DataMapper.repository(:local) { BaseSample.auto_upgrade! }

markov_chain = MetropolisHastingsMarkovChain.new
sample = ZSample.new
if sample.last_node
  previous_node = TwitterNode.new(sample.last_node)
else
  previous_node = TwitterNode.new(16450138)
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
  sample.save!(current_node) { |node| node.degree }
  previous_node = current_node
end

puts sample.expectation_value