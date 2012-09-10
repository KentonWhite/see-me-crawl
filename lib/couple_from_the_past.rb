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

  # Sept 9, 2012, John
  #
  # description: given initial states, the algorithm produces non-trivial states for further perfect sampling.
  # The results for non trivial states are obtained in terms of tm, the minimum coupling time,
  # and then mutiple repetitions for aggregation; the general requirement about non-trivial states is 
  # independent enough among non trivial states.
  #
  # note: an alternative to aggregation_by_backward_coupling algorithm (where m = max_size, dist = tm)
  #
  # t0: initial time translation, tm: minimum coupling time,
  # t0, tm, num_iterations, max_size: all are domain related parameters; they can be empirically set;
  #
  def non_trivial_states(init_states, max_size = 1024, tm = -32, t0 = 0, num_iterations = 100)
	
    prng = Random.new()
    random_seq = Array.new()
	
    n_states = Hash.new
    init_states.each {|e| n_states.store(e.id, e)}
	  
    return n_states.values if n_states.size >= max_size
	
    for i in 0..num_iterations - 1
    
      curr_T = -1
      old_T = 0	
		
      @random_maps.clear				
      random_seq.clear
			
      curr_size = n_states.size
      begin	
        num = old_T - curr_T - t0
        rs	= random_numbers(num, prng)
        random_seq = random_seq + rs
			
        results = n_states
			
        t = curr_T + t0;
        while t < 0 do
          u = random_seq.at(-t-1)			
          results = update(results, u, t)
          t += 1
        end
						
        n_states.merge!(results)
        break if curr_T <= tm

        old_T = curr_T
        curr_T = 2 * curr_T
      end while true
				
      p "#{n_states.keys}"
		
      DataMapper.repository(:local) do 
        n_states.keys.each do |r|
          state = NonTrivialState.first_or_create(node: r)
        end
      end	
      break if n_states.size >= max_size or n_states.size == curr_size
    end 
    n_states.values
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
  # Sept 9, 2012, John
  # Description: Given an initial_states, which is regarded as non-trivial states, 
  # this produces a perfect sample by using a new method for coupling, which is called 
  # the generalized backward coupling technique.
  #
  # Note: an alternative to online_cftp, and it is used together with other algorithms for generating non-trivial states, e.g., 
  # aggregation_by_backward_coupling or non_trivial_states algorithms
  #
  # Inputs: init_states, which is used as non-trivial states, are generated beforehand, 
  # e.g., by aggregation_by_backward_coupling, those non-trivial states are required to be independent nodes; 
  # t0 = 0 or -5, initial time translation; 
  # tm, default = -32, the minimum coupling time (empirical guess), which can be automatically learned
  # 

  def generalized_cftp(init_states, t0 = -5, tm = -32)
	
    random_seq = Array.new()
    @random_maps.clear				
	
    # generated non-trivial states
    n_states = Hash.new
	
    init_states.each {|e| n_states.store(e.id, e)}
	
    # working states
    w_states = n_states.clone
	
    # visited intermediate states
    v_states = n_states.clone
	
    curr_T = -1
    old_T = 0
	
    begin	
      num = - random_seq.size - curr_T - t0
      if num > 0
        rs	= random_numbers(num, @prng)
        random_seq = random_seq + rs
      end
		
      results = w_states
		
      t = curr_T + t0;
      while t < 0 do
        u = random_seq.at(-t-1)			
        results = update(results, u, t);
        t += 1;	
      end
				
      return results.values if results.size == 1	
		
      w_states = results
      w_states.delete_if{|k, x| v_states.has_key?(k)}
      if !w_states.empty?
        v_states.merge!(w_states)
        next
      end
      w_states = n_states.clone
      v_states = n_states.clone		

      old_T = curr_T
      curr_T = 2 * curr_T
      #p "w_states#{w_states.size}"
    end while true
  end 

  # John, Sept 5, 2012, modified Sept 9, 2012
  # 
  # Description: given initial states for starting, the algorithm produces a perfect sample by
  # creating a non-trivial state set and using the generalized backward coupling technique proposed 
  # in this new research
  #
  # input: init_states for starting; 
  # t0 and tm: by default, the initial translate time, t0 = 0 or -5; 
  # the minimum coalescence time, tm = -2^10 = -1024, domain-related setting
  #
  # improved online_cftp by combination of aggregation_by_backward_coupling and online_cftp:
  # 1) t0 for avoiding a trivial stop;
  # 2) automatically learn tm; 
  # 3) the stop condition is to coelesce to single value.
  #
  def increment_cftp(init_states, t0 = -0, tm = -32)
	
    random_seq = Array.new()
    @random_maps.clear				
	
    # resulting non-trivial states
    n_states = Hash.new
	
    # working states
    w_states = Hash.new
	
    init_states.each {|e| w_states.store(e.id, e)}

    # visited intermediate states
    v_states = Hash.new
	
    curr_T = -1
    old_T = 0
	
    begin	
      num = - random_seq.size - curr_T - t0
      if num > 0
        rs	= random_numbers(num, @prng)
        random_seq = random_seq + rs
      end
		
      results = w_states
		
      t = curr_T + t0;
      while t < 0 do
        u = random_seq.at(-t-1)			
        results = update(results, u, t);
        t += 1;	
      end
				
      if curr_T <= tm
        return results.values if results.size == 1
			
        w_states = results
        w_states.delete_if{|k, x| v_states.has_key?(k)}
			
        if !w_states.empty?
          v_states.merge!(w_states)
          #p "propagation: w_states#{w_states.size}"
          next
        end
        w_states = n_states.clone
        v_states = n_states.clone
      else
        w_states.merge!(results)
        n_states = w_states.clone
        v_states = w_states.clone
      end
      #p "0? #{w_states.size}, #{v_states.size}, #{n_states.size}"

      old_T = curr_T
      curr_T = 2 * curr_T
      #p "backward: w_states#{w_states.size}"
    end while true
  end 
end
