require './lib/couple_from_the_past.rb'  
require './lib/z_sample.rb'
require './lib/twitter_node.rb'  

DataMapper.setup(:default, adapter: 'postgres', host: 'ec2-23-21-119-36.compute-1.amazonaws.com', port: 5432, database: 'd4v6cj037h29c7', user: 'nedardynmyjtbv', password: '0kaxSe1KU3YF8czv6jXUj0Qy4T')

DataMapper.setup(:local, adapter: 'postgres', host: 'ec2-23-21-119-36.compute-1.amazonaws.com', port: 5432, database: 'd4v6cj037h29c7', user: 'nedardynmyjtbv', password: '0kaxSe1KU3YF8czv6jXUj0Qy4T')

DataMapper.auto_upgrade!
DataMapper.repository(:local) { Sample.auto_upgrade! }
DataMapper.repository(:local) { NonTrivialState.auto_upgrade! }

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

init_states = Array.new
non_trivial_states = DataMapper.repository(:local) { NonTrivialState.all }

if non_trivial_states.empty? then
  p "first node  #{previous_node.id}"
  init_states.push previous_node
else
  puts "Restarting from with the following non trivial states:"
  p non_trivial_states
  non_trivial_states.each do |nts|
    init_states.push TwitterNode.new(nts.node)
  end
end

# sample_size and min_coupling_time are domain-related, 
# e.g., empirically, sample_size = 100k and min_coupling_time = 1000 in Facebook; 
# In particular, min_coupling_time = 0 for undefined or no limited
sample_size = 10
min_coupling_time = 5

# generating a state space
generating_non_trivial_states = false

if generating_non_trivial_states
	non_trivial_states = cftp.aggregation_by_backward_coupling(init_states, sample_size, min_coupling_time)
end

p "cftp..."

i = 0
while true do
	
	if generating_non_trivial_states
		samples = cftp.cftp(-1, non_trivial_states, min_coupling_time)
	else
		# using online_cftp, and then not need non_trivial-states
		#samples = cftp.online_cftp(init_states, sample_size, min_coupling_time)
		samples = cftp.increment_cftp(init_states)
	end
	
  p samples
	samples.each do |current_node|
		sample.save!(current_node) { |node| node.degree }
		
		# augment non-trivial states
		init_states = [current_node]
	end
	i += samples.size
	p "samples =#{i}"
end
	
 