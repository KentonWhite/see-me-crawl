require './lib/base_sample.rb'
require './lib/variance.rb'
require 'statsample'

class ZSample
  attr_reader :count, :min_iterations
  def initialize(min_iterations = 1e3)
    @count = DataMapper.repository(:local) { BaseSample.count }
    @min_iterations = min_iterations
  end
  
  def save!(node)
    node_id = node.id
    deg = node.degree
    
    puts "degree:", deg
    
    value = yield node
    monitor = z_statistic
    DataMapper.repository(:local) do 
      BaseSample.create(node: node_id, degree: deg, value: value, monitor: monitor)
    end
    @count += 1
  end 
  
  def last
    DataMapper.repository(:local) { BaseSample.last }
  end
  
  def last_node
    sample = DataMapper.repository(:local) { BaseSample.last }
    if sample
      sample.node 
    else
      nil
    end
  end
  
  def converged?
    count > min_iterations && in_confidence_interval?(0.95)
  end
  
  def expectation_value
    tail(:value, 0.5, :desc).mean
  end
  
  private
  
  def z_statistic
    ea = tail(:value, 0.1, :asc)
    eb = tail(:value, 0.5, :desc)
    numer = (ea.mean - eb.mean)
    return 0.0 if numer.nan?
    denom = Math.sqrt(ea.variance + eb.variance)
    return 0.0 if denom == 0.0 
    numer/denom
  end 
  
  def tail(field, percent, order)
    DataMapper.repository(:local) do
      BaseSample.all(:fields => [field], :order => [:id.send(order)], :limit => (count*percent).ceil).map {|s| s.send(field)}
    end
  end
  
  def in_confidence_interval?(interval)
    val = tail(:monitor, 0.1, :desc).mean
    ci = confidence_interval(interval) 
    val > ci.first && val < ci.last    
  end
  
  def confidence_interval(interval)
    Statsample::SRS::mean_confidence_interval_z(0, 1, 0.1*count, count, interval)
  end
end