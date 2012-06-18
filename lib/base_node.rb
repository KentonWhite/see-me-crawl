require './lib/graph.rb'
require 'chronic'
require 'dalli'
require 'set'

class BaseNode
  
  @@cache = Dalli::Client.new('localhost:11211', expires_in: 604800)
  
  class MethodNotImplemented < StandardError; end 
  
  attr_reader :id, :in_degree, :out_degree, :visited_at, :crawled_at, :private
  
  def initialize(id) 
    @id = id
    # columns.each { |col| self.instance_eval "def #{col}; @#{col}; end" } 
    populate_from_db
  end 
  
  def degree
    @degree ||= in_degree.to_i + out_degree.to_i
  end
  
  def connections
    friends + followers
  end
  
  def friends
    @friends ||= (puts "Friends SelectGet"; Edge.all(n1: id).map { |e| e.n2 })
  end
  
  def followers
    @followers ||= (puts "Followers SelectGet"; Edge.all(n2: id).map { |e| e.n1 })    
  end
  
  def private?
    private
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
    edges.each do |type, list|
      new_edges = Set.new(list - self.send(type))
        case type
        when :friends
          puts "Update Edges PutAttribute x #{new_edges.size}"
          new_edges.each do |n|
            begin 
              Edge.create(n1: id, n2: n) 
            rescue DataObjects::IntegrityError => e
              puts "Error writing edge (#{id}, #{n})"
              puts "Skipping"
            end
          end
        when :followers
          puts "Update Edges PutAttribute x #{new_edges.size}"
          new_edges.each do |n|
            begin 
              Edge.create(n1: n, n2: id) 
            rescue DataObjects::IntegrityError => e
              puts "Error writing edge (#{n}, #{id})"
              puts "Skipping"
            end              
          end
        end
        self.instance_variable_set("@#{type}", list)
    end 
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