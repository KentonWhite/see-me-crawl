require 'dm-chunked_query'

class Entropy
  attr_accessor :distribution, :total_degree
  
  def initialize
    @distribution = Hash.new(0)
    @total_degree = 0
    load_distribution
  end
  
  def load_distribution
    Sample.each_chunk(20) do |chunk|
      chunk.each do |s|
        add_node s
      end
    end
  end
  
  def add_node(node)
    @distribution[node.degree] += 1
    @total_degree += node.degree
  end
  
  def q(degree)
    degree*@distribution[degree]/total_degree.to_f
  end
  
  def entropy
    @distribution.reduce(0) { |h, (degree, n)| qi = degree*n/total_degree.to_f; h - qi*Math.log(qi) }
  end
  
  def entropy!(node)
    add_node(node)
    entropy
  end
end