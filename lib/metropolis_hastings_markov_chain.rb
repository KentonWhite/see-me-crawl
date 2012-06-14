require './lib/markov_chain.rb'
class MetropolisHastingsMarkovChain < MarkovChain 
  def acceptance_probability(current_node, candidate_node)
    return 1.0 if candidate_node.degree == 0
    [1.0, current_node.degree.to_f/candidate_node.degree.to_f].min
  end
end