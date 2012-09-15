require './lib/graph.rb'
require 'chronic'
require 'dalli'
require 'set'
require 'trollop'

class BaseNode
  
  class NullCache
    def get(id)
      
    end
    
    def set(id, obj)
      
    end
  end

  opts = Trollop::options do
    opt :memcached, "Use memcached", :default => false
  end
  
  @@cache = opts[:memcached] ? Dalli::Client.new('localhost:11211', expires_in: 604800) : NullCache.new
  
  class MethodNotImplemented < StandardError; end 
  
  attr_reader :id, :in_degree, :out_degree, :visited_at, :crawled_at, :private
  
  def initialize(id) 
    @id = id.to_int
    # columns.each { |col| self.instance_eval "def #{col}; @#{col}; end" } 
    populate_from_db
  end 
  
  def degree
    in_degree.to_i + out_degree.to_i
  end
  
  def connections
    friends + followers
  end
  
  def friends
    @friends ||= (puts "Friends SelectGet"; Edge.get(id).friends)
  end
  
  def followers
    @followers ||= (puts "Followers SelectGet"; Edge.get(id).followers)   
  end
  
  def private?
    private || degree == 0
  end 
  
  def new_node(new_id)
    new_node = @@cache.get(new_id)
    if new_node && new_node.degree != 0
      new_node
    else
      new_node = self.class.new(new_id)
      @@cache.set(new_id, new_node)
    end
    new_node
  end 
  
  def crawl! 
    raise MethodNotImplemented, 'Please implement crawl! in a subclass' 
  end

  protected
  
  def populated?
    @populated
  end
  
  def stale?(time)
    return true if time.nil?
    time < Chronic.parse('1 week ago').to_datetime  
  end

  def save!
    n = Node.first(id: id)
    @visited_at = DateTime.now
    params = columns.reduce({}) { |h,p| h[p] = self.send(p); h }
    puts "Save! PutAttribute" 
    if n
      n.update(params)
    else
      Node.create(params)      
    end
    begin
      @@cache.set(id, self)
    rescue Dalli::DalliError => e
      p e
      puts "Skipping cache step"
    end
  end
  
  def update_edges(edges) 
    puts "Updating edges (friends: #{edges[:friends].size}, followers: #{edges[:followers].size}...)"
    db_edges = Edge.first_or_new(id: id)
    db_edges.friends = edges[:friends]
    db_edges.followers = edges[:followers]
    db_edges.save!
    puts "Done updating edges"
  end

  private
  
  def populate_from_db
    puts "Populate SelectGet"
    n = Node.get(id)
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