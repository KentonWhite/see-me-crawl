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
    end until (d >= dist and dist > 0) or results.size == 1 
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
      end until (d >= dist and dist > 0) or curr_results.size == 1
		
      results = results.merge(curr_results)
		
      p "#{results.keys}"
      DataMapper.repository(:local) do 
        results.keys.each do |r|
          state = NonTrivialState.first_or_create(node: r)
        end
      end
    end until results.size >= m or (results.size > init_states.size and results.size <= curr_size)
    results.values
  end

  # online cftp, from aggregation_by_backward_coupling
  # init_states, m: the maximum state space, dist: the minimum coupling time
  # empirically, m = 100k, dist = 3000, for Facebook, domain-related setting
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
      results = Hash.new()
		
      d = 0
		
      begin	
        num = - random_seq.size - curr_T
        if num > 0
          rs	= random_numbers(num, @prng)
          random_seq = random_seq + rs
        end
			
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
        p "d=#{d} coalesce=#{results.size}, #{results.keys}"
      end until (d >= dist and dist > 0) or results.size == 1
				
      p "states = #{states.keys}"		
      break if states.size >= m		
      states = states.merge(results)
    end until states.size > init_states.size and states.size <= curr_size
    results.values
  end
  # John, Sept 5, 2012
  # 
  # init_states, m: the maximum state space, dist: the minimum coupling time
  # by default, the initial translate time, t0 = 0 or -5; the minimum coalescence time, tm = -2^10 = -1024, domain-related setting
  #
  # improved online_cftp:
  # 1) t0 for avoiding a trivial stop;
  # 1) automatically learn tm; 
  # 2) the stop condition is to coelesce to single value.
  #
  def increment_cftp(init_states, t0 = -5, tm = -1024)
	
    random_seq = Array.new()
    @random_maps.clear				
	
    # generated non-trivial states
    n_states = Hash.new
	
    # working states
    w_states = Hash.new
	
    # visited intermediate states
    v_states = Hash.new
	
    init_states.each {|e| w_states.store(e.id, e)}

    curr_T = -1
    old_T = 0
	
    begin	
      begin	
        p w_states.keys	
        num = - random_seq.size - curr_T - t0
        if num > 0
          rs	= random_numbers(num, @prng)
          random_seq = random_seq + rs
        end
			
        results = w_states
			
        t = curr_T + t0;
        while t < 0 do
          u = random_seq.at(-t-1)		
          puts "Time step:\t#{t}.  Calling update..."	
          results = update(results, u, t);
          puts "update done!"
          p results.keys
          t += 1;	
        end
				
        puts "Curr_T:\t#{curr_T}\ttm:\t#{tm}"	
        if curr_T <= tm
          puts "Results size:\t#{results.size}"
          return results.values if results.size == 1
			
          puts "Pruning w_states"
          p v_states.keys
          w_states = results.delete_if{|k, x| v_states.has_key?(k)}
          p w_states.keys
          break if w_states.empty?
				
          v_states.merge!(results)
          next
        else
          w_states.merge!(results)
          n_states = w_states				
        end
        old_T = curr_T
        curr_T = 2 * curr_T
        p "w_states#{w_states.size}"
      end while true
		
      # p "w_states#{w_states.size}"	
      puts "n_states"
      p n_states.keys
		
      w_states = n_states
      v_states.clear
		
      old_T = curr_T
      curr_T = 2 * curr_T
		
      # stop backward coupling (or continue for autmatically learning tm)
      # break
    end while true
  end 
end
