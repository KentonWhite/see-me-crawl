require './lib/coupling_markov_chains.rb'
require './lib/sample.rb'

class CoupleFromThePast < CouplingMarkovChains

  def initialize()
	# initialize random_maps
	super()
	
	# random numbers for independent coupling
    @prng = Random.new()
  end 
 
 # refer to: Perfect Sampling Algorithms: Connections, Duncan Murdoch
 # m: initial time <0, nodes:states, {x}, dist: minimum iteration
 
 def cftp(m, nodes, dist)
	curr_T = m
	old_T = 0
	
	random_seq = Array.new()
	## @prng = Random.new()
  
  @random_maps.clear
	
	states = Hash.new
	nodes.each{|e| states.store(e.id, e)}
	
	# for non-uniform coupling to avoid deadlock
	d = 0
	
	begin
	
		n = old_T - curr_T
    rs = random_numbers(n, @prng)		
    random_seq = random_seq + rs
    		
		results = states
		t = curr_T;
		while t < 0 do
			u = random_seq.at(-t-1)
			results = update(results, u, t);
			t += 1;
		end
		
		old_T = curr_T
		curr_T = 2 * curr_T
		d += 1
	end until d >= dist or results.size == 1 
	results.values
 end
 
 # independent perfect samples, m: num of iterations
 def independent_cftp(init_states, m, dist)
    
    states = aggregation_by_backward_coupling(init_states, m, dist)
    
	results = Array.new()
	i = 0
	while i < m do 
		b = cftp(-1, states, dist)
		results = results + b
		i += 1
	end
	results
 end
 
 # backward propagation or search
 # may need lib/set.rb
 # m: sample size, x: initial sample seeds, dist: time distance or mininal couling time
 
 def aggregation_by_backward_coupling(init_states, m, dist)
	
	prng = Random.new()
	random_seq = Array.new()
	
	results = Hash.new
	init_states.each {|e| results.store(e.id, e)}
	
	samplesize = 0
  
  return results.values if results.size >= dist
	
	begin
    
		curr_T = -1
		old_T = 0	
			
		curr_size = results.size		
		curr_results = Hash.new()
		
		d = 0
		@random_maps.clear				
		random_seq.clear
		
		begin	
			num = old_T - curr_T
			rs	= random_numbers(num, prng)
			random_seq = random_seq + rs
			
			curr_results = results
			t = curr_T;
			while t < 0 do
				u = random_seq.at(-t-1)
				
				curr_results = update(curr_results, u, t);
				t += 1;
			end
			old_T = curr_T
			curr_T = 2 * curr_T
			d += 1
			p "#{d}"
		end until d >= dist or curr_results.size == 1
		
		results = results.merge(curr_results)
		
		p "#{results.keys}"
    DataMapper.repository(:local) do 
      results.keys.each do |r|
        state = NonTrivialState.first_or_create(node: r)
      end
    end
	end until results.size >= m or results.size <= curr_size
	results.values
 end

 # online cftp, from aggregation_by_backward_coupling
 # init_states, m: the maximum state space, dist: the minimum coupling time
 # empirically, m = 100k, dist = 1000, for Facebook, domain-related setting
 def online_cftp(init_states, m, dist)
	
	random_seq = Array.new()
	@random_maps.clear				
	
	states = Hash.new
	init_states.each {|e| states.store(e.id, e)}
	
	samplesize = 0
	begin
		curr_T = -1
		old_T = 0	
			
		curr_size = states.size		
		curr_results = Hash.new()
		
		d = 0
		
		begin	
			#num = old_T - curr_T
			num = - random_seq.size - curr_T
			if num > 0
				rs	= random_numbers(num, @prng)
				random_seq = random_seq + rs
			end
			
			curr_results = states
			t = curr_T;
			while t < 0 do
				u = random_seq.at(-t-1)
				
				curr_results = update(curr_results, u, t);
				t += 1;		
			end
			old_T = curr_T
			curr_T = 2 * curr_T
			d += 1
			p "d=#{d} coalesce=#{curr_results.size}"
		end until d >= dist or curr_results.size == 1
				
		p "states = #{states.keys}"
		states = states.merge(curr_results)		
	end until states.size >= m or (states.size <= curr_size and states.size > init_states.size)
	curr_results.values

end