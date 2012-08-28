require './lib/metropolis_hastings_markov_chain.rb'
require './lib/graph.rb'

#require 'chronic'
#require 'dalli'

class CouplingMarkovChains < MetropolisHastingsMarkovChain

  def initialize() 
	# a novel method for random maps[t, id] => node; 
	# can be defined as a cache instead of a simple hash
	@random_maps = Hash.new
  end 
    
  # Define a random map using RW/MH method
  # current_node: state, u: random value, t, rw
  # true-RW/false-MH
  def nextRWMH(current_node, u, t, rw)
	nodes = current_node.connections
	node = current_node

	if nodes.empty?
		current_node.crawl!
		nodes = current_node.connections
    end	
	
    raise NoValidNextNode if nodes.empty?

	sumpij = 0
	pi = 1 / current_node.degree.to_f
	
	nodes.each do |i|
	    candidate_node = current_node.new_node(i)
        
		if candidate_node.private?
			next
		end
		       
		pj = 1 / candidate_node.degree.to_f
		pij = pj
		if !rw
			pij = [pi, pj].min
		end
	
		if sumpij < u and u  <= sumpij + pij
		  node = candidate_node
  		  
		 # puts "1 #{sumpij}, #{u}, #{sumpij + pij}"
		
		  break
		end
		sumpij += pij
	end
	
	keya = Array[t, current_node.id]
	@random_maps.store(keya, candidate_node.id)if !candidate_node.nil?
	
	node
  end
  
  # define a random map using RW/MH, another efficient method
  # rw: true-RW/false-MH
  def nextRWMH!(current_node, u, t, rw)
	candidate_node = select_candidate!(current_node, u, t)
	node = candidate_node
	if !rw
		node = choose_node(current_node, candidate_node)
	end
	
	keya = Array[t, current_node.id]
	@random_maps.store(keya, node.id) if !node.nil?
	 
	node
  end

  # select candidate with u given t by using randon maps
  def select_candidate!(current_node, u, t)
  
    keya = Array[t, current_node.id]
	if @random_maps.has_key?(keya)
    puts "Retrieving candiate for #{current_node.id} from cache"
		candidate_node = current_node.new_node(@random_maps[keya])
		return candidate_node
	end
    
  puts "Retrieving candiate for #{current_node.id}"
	current_node.crawl! if current_node.crawled_at.nil?
    nodes = current_node.connections
       
    #nodes.shuffle!
    
    rng = nodes.size * u + 1 
    #nodes.shuffle!(Randon.new(rng.to_i)), in Ruby 1.9.3
    
    nodes = shuffle(nodes, rng.to_i)
    begin
      raise NoValidNextNode if nodes.empty?
      candidate_node = current_node.new_node(nodes.shift)
      # puts "candidate_node: #{candidate_node.id} private? #{candidate_node.private?}" 
    end while candidate_node.private?
    
    candidate_node
  end
  
# refer to http://www.dreamincode.net/code/snippet4682.htm
# shuffle with seed s
 def shuffle(arr, s)
  rng = Random.new(s)
  for i in 0..arr.length - 1
    j = rng.rand(arr.length)
    tmp = arr[i]
    arr[i] = arr[j]
    arr[j] = tmp
    #p "#{i}, #{arr.length}"
  end
  return arr
 end

  # the update function for random maps in coupling techniques
  # nodes: a hash of nodes; u: random number, t: current time step
  def update(nodes, u, t)
  
	new_values = Hash.new()
			
	nodes.each_value do |x|
		new_node = nextRWMH!(x, u, t, true)
		#new_node = nextRWMH(x, u, t, false)
							
		if !new_node.nil?
			n = Node.get(new_node.id)
		
			new_node.crawl! if n.nil? or n == nil or new_node.crawled_at.nil?
			new_values.store(new_node.id, new_node)
		end
		
	end
	new_values
  end
     
  # n: number of random values, prng: random generator
  def random_numbers(n, prng)
    rs = Array.new
	i = 0
	while i < n do
		rs.push prng.rand;
		i += 1
	end
	rs
  end
  
  # overriding
  def accept?(candidate_node, current_node)
    #rand <= acceptance_probability!(current_node, candidate_node)  
    rand <= acceptance_probability(current_node, candidate_node)
  end
  
  # the acceptance probability for MH; which is bias to high degree
  def acceptance_probability!(current_node, candidate_node)
    [1.0, candidate_node.degree.to_f/current_node.degree.to_f].min
  end
  
end