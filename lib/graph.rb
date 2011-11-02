require 'data_mapper'

class Node
  include DataMapper::Resource

  property :id,         Integer, :min => 0, :max => 2**32, :key => true
  property :in_degree,  Integer
  property :out_degree, Integer
  property :visited_at, DateTime
  property :private,    Boolean,  :default => false 
end