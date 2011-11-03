require './lib/graph.rb'

class BaseNode
  def initialize(id)
    @id = id 
    columns.each { |col| self.instance_eval "def #{col}; @#{col}; end" } 
    populate_from_db
  end 
  
  def degree
    in_degree.to_i + out_degree.to_i
  end
  
  def connections
    friends + followers
  end
  
  def friends
    Edge.all(n1: id).map { |e| e.n2 }
  end
  
  def followers
    Edge.all(n2: id).map { |e| e.n1 }    
  end
  
  def private?
    private
  end 
  
  def new_node(id)
    self.class.new(id)
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