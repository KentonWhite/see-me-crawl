require './lib/sample.rb'

class BaseSample
  class MethodNotImplemented < StandardError; end 
  attr_reader :count, :min_iterations
  def initialize(min_iterations = 1e3)
    @count = DataMapper.repository(:local) { Sample.count }
    @min_iterations = min_iterations
  end
  
  def save!(node)
    node_id = node.id
    degree = node.degree
    value = yield node
    DataMapper.repository(:local) do 
      begin
        Sample.create(node: node_id, degree: degree, value: value, monitor: monitor)
      rescue DataObjects::SQLError => e
        p e.message
        retry
      end
    end
    @count += 1
  end 
  
  def last
    DataMapper.repository(:local) { Sample.last }
  end
  
  def last_node
    sample = DataMapper.repository(:local) { Sample.last }
    if sample
      sample.node 
    else
      nil
    end
  end
  
  def converged?
    raise MethodNotImplemented, 'Please implement crawl! in a subclass' 
  end
  
  def monitor
    1
  end
  
end
