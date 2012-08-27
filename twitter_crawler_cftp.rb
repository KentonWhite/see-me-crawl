require './lib/couple_from_the_past.rb'  
require './lib/z_sample.rb'
require './lib/twitter_node.rb'  

DataMapper.setup(:default, adapter: 'mysql', database: 'graph', user: 'root')

DataMapper.setup(:local, adapter: 'mysql', database: 'sample', user: 'root')

DataMapper.auto_upgrade!
DataMapper.repository(:local) { Sample.auto_upgrade! }

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
	
 