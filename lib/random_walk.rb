require './lib/markov_chain.rb'
class RandomWalk < MarkovChain 
  def acceptance_probability(current_node, candidate_node)
    1.0
  end
end
