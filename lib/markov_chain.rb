
class MarkovChain
  class NoValidNextNode < StandardError; end
  class MethodNotImplemented < StandardError; end

  def next(current_node)
    candidate_node = select_candidate(current_node)
    rand <= acceptance_probability(current_node, candidate_node) ?
      candidate_node : current_node
  end
  
  def select_candidate(current_node)
    nodes = current_node.connections
    nodes.shuffle!
    begin
      raise NoValidNextNode if nodes.empty?
      candidate_node = current_node.new_node(nodes.shift) 
    end while candidate_node.private?
    candidate_node
  end
  
  def acceptance_probability(current_node, candidate_node) 
    raise MethodNotImplemented, 'Please implement acceptance_probability in a subclass' 
  end
  
end