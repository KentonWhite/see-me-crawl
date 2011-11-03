require 'data_mapper'

class Node
  include DataMapper::Resource

  property :id,         Integer, min: 0, max: 2**32, key: true
  property :in_degree,  Integer
  property :out_degree, Integer
  property :visited_at, DateTime
  property :private,    Boolean,  default: false 
end

class Edge
  include DataMapper::Resource
  property :n1,  Integer, min: 0, max: 2**32, key: true
  property :n2,  Integer, min: 0, max: 2**32, key: true    
end     