class MarkovChain
  def next(current_node)
    candidate_node = select_candidate(current_node)
    rand <= acceptance_probability(current_node, candidate_node) ?
      candidate_node : current_node
  end
end