Sampling online social network using CFTP

Guichong Li, Aug 24, 2012


1. A short description

   This implements sampling online social networks using CFTP based on the previous version for crawling online using MH.

   The previous codes are not changed! The new codes include 

   twitter_crawler_cftp.rb
   coupling_markov_chains.rb
   coupling_from_the_past.rb
   lru_cache.rb

   
   In the new version, it proposes a novel method( using @random_maps) for fast coalescence detection. 
   Instead of Dallie:: Cache, it uses a tool for ruby cache in PC. 

   To avoid a long run for coalescence in the standard CFTP, it is limited with a fixed number of iterations. 
   The standard CFTP might not coalesce to a single value because of non-uniform convegence rate for chains.

   For use, refer to 2.

   For clusting computation, one should modify the cache method in base_node.rb:

	# for cache in PC, John
	require './lib/lru_cache.rb' 							(should be removed)

	class BaseNode
  		# cache using Dalli on Sever; LRUCache for PC, John
  		#@@cache = Dalli::Client.new('localhost:11211', :expires_in => 604800)  (should be enabled)
  		@@cache = LRUCache.new							(should be diabled)
   
   This is only change as above in the previous code.   

   You may want to change the method for selecting a candidate with bias to high degree nodes in MH, then you need to change 

in coupling_markov_chains.rb:

  # overriding
  def accept?(candidate_node, current_node)
    #rand <= acceptance_probability!(current_node, candidate_node)  	(should be enabled, new codes by rewriting the original code)
    rand <= acceptance_probability(current_node, candidate_node)	(should be disabled from the previous code)
  end
  
  In fact, there are 4 ways for selecting a candidate, by using nextRWMH() and nextRWMH!(). nextRWMH!() may be more efficient than nextRWMH(). 
  Default is random MH with bias to lower degree nodes.
  
  So far, new codes are not controlled by using version management, and they are not run in clustering environment for a largescale computation.


2. usage

   Given sample_size = 20, min_coupling_time = 5, or practically 100k and 100, respectively
  
   ruby twitter_crawler_cftp.rb

   It must be provided a specified sample_size and min_coupling_time by modifying them


3. new codes(files)

   twitter_crawler_cftp.rb, 	by modifying twitter_crawler.rb

   coupling_markov_chains.rb, 	methods for general coupling, 
				i.e., nextRWMH() and nextRWMH!() methods for next candidates using RW and MH methods; 
				update_function() method for update function; 
				@random_maps for coalescence test; 
				random_numbers() for generating random numbers; 
				shuffle() for shuffling array with a seed;
				select_candidate!(), rewritten for selecting a candidate

   couple_from_the_past.rb, 	methods for CFTP, i.e., standard CFTP for a perfect sample, independent CFTP for perfect samples, 
				aggregation_by_backward_coupling for non-trivial state space

   lru_cache.rb, 		a tool for cache in PC instead of Dalli::Cache

   Other unused codes

   set.rb
   stack.rb
   LinkedList.rb
   queue.rb

   They may be used in future.

4. correction


  # define a random map using RW/MH, another efficient method
  # rw: true-RW/false-MH
  def nextRWMH!(current_node, u, t, rw)
	candidate_node = select_candidate!(current_node, u, t)
	node = candidate_node
	if !rw
		node = choose_node(current_node, candidate_node)
	end
	
	keya = Array[t, node.id]			should be: keya = Array[t, current_node.id]
	@random_maps.store(keya, node)  
	 
	node
  end


...


  # the update function for random maps in coupling techniques
  # nodes: a hash of nodes; u: random number, t: current time step
  def update(nodes, u, t)
  
	new_values = Hash.new()
			
	nodes.each do |k, x|
		new_node = nextRWMH!(x, u, t, false); 
		#new_node = nextRWMH(x, u, t, false);
						
		n = Node.get(new_node.id);
		new_node.crawl! if !n || new_node.crawled_at.nil?;   should be: new_node.crawl! if n.nil? || n == nil || new_node.crawled_at.nil?;
		
		new_values.store(new_node.id, new_node);
		
	end
	new_values
  end

or modified as

  # the update function for random maps in coupling techniques
  # nodes: a hash of nodes; u: random number, t: current time step
  def update(nodes, u, t)
  
	new_values = Hash.new()
			
	nodes.each_value do |x|
		new_node = nextRWMH!(x, u, t, false)
		#new_node = nextRWMH(x, u, t, false)
							
		if !new_node.nil?
			n = Node.get(new_node.id)
		
			new_node.crawl! if n.nil? or n == nil or new_node.crawled_at.nil?
			new_values.store(new_node.id, new_node)
		end
		
	end
	new_values
  end


End
