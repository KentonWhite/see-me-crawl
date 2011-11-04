require './lib/graph.rb'

class BaseNode
  class MethodNotImplemented < StandardError; end
  
  def initialize(id)
    @id = id 
    columns.each { |col| self.instance_eval "def #{col}; @#{col}; end" } 
    populate_from_db
  end 
  
  def degree
    @degree ||= in_degree.to_i + out_degree.to_i
  end
  
  def connections
    friends + followers
  end
  
  def friends
    @friends ||= Edge.all(n1: id).map { |e| e.n2 }
  end
  
  def followers
    @followers ||= Edge.all(n2: id).map { |e| e.n1 }    
  end
  
  def private?
    private
  end 
  
  def new_node(id)
    self.class.new(id)
  end 
  
  def crawl! 
    raise MethodNotImplemented, 'Please implement crawl! in a subclass' 
  end

  protected
  
  def populated?
    @populated
  end
  
  def save!
    n = Node.first(id: id)
    params = columns.reduce({}) { |h,p| h[p] = self.send(p); h }
    params[:visited_at] = DateTime.now 
    if n
      n.update(params)
    else
      Node.create(params)      
    end
  end
  
  def update_edges(edges) 
    edges.each do |type, list|
      new_edges = list - self.send(type)
      case type
      when :friends
        new_edges.each { |n| Edge.create(n1: id, n2: n) }
      when :followers
        new_edges.each { |n| Edge.create(n1: n, n2: id) }
      end
      self.instance_variable_set("@#{type}", list)
    end 
  end

  private
  
  def populate_from_db
    n = Node.first(id: id)
    if n
      columns.each { |col| self.instance_variable_set("@#{col}", n.send(col)) }
      @populated = true
    else
      @populated = false
    end
  end 
  
  def columns
    Node.properties.map { |prop| prop.name }
  end
end