require 'data_mapper'
require 'dm-pg-types'

class Node
  include DataMapper::Resource

  property :id,         Integer, min: 0, max: 2**32-1, key: true
  property :in_degree,  Integer
  property :out_degree, Integer
  property :visited_at, DateTime
  property :crawled_at, DateTime
  property :private,    Boolean,  default: false 
end

class Edge
  include DataMapper::Resource
  property :id,  Integer, min: 0, max: 2**32-1, key: true
  property :friends, DecimalArray, precision: 20, scale: 10
  property :followers, DecimalArray, precision: 20, scale: 10
end     