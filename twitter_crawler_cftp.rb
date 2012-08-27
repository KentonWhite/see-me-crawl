require './lib/couple_from_the_past.rb'  
require './lib/z_sample.rb'
require './lib/twitter_node.rb'  

DataMapper.setup(:default, adapter: 'sqlite3', database: 'graph.db')

# DataMapper.setup(:default, 
#   adapter:    'simpledb',
#   access_key: 'AKIAJOOPW5QN4DZJG2BA',
#   secret_key: 'xPedqv6zdtPtxsM/PtxiB6kXrgNb5C9Y9R19JvR1',
#   domain:     'gertrude-stein-tw', 
# )

DataMapper.setup(:local, adapter: 'sqlite3', database: 'sample.db')

DataMapper.auto_upgrade!

DataMapper.repository(:local) { BaseSample.auto_upgrade! }

#markov_chain = MetropolisHastingsMarkovChain.new

cftp = CoupleFromThePast.new
#coupling = CouplingMarkovChains

sample = ZSample.new
if sample.last_node
  previous_node = TwitterNode.new(sample.last_node)
else
	
  previous_node = TwitterNode.new(16450138)
   
  previous_node.crawl!
  
end  

p "first node  #{previous_node.id}"

init_states = Array.new
init_states.push previous_node

sample_size = 20
min_coupling_time = 5

non_trivial_states = cftp.aggregation_by_backward_coupling(init_states, sample_size, min_coupling_time)

p "cftp..."
i = 0
while i < sample_size do
	samples = cftp(-1, non_trivial_states, min_coupling_time)
	
	samples.each do |current_node|
		sample.save!(current_node) { |node| node.degree }
	end
	i += samples.size
end
	
 