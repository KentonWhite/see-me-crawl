require 'data_mapper'
require 'dm-chunked_query'

class Sample
  include DataMapper::Resource 
  include DataMapper::ChunkedQuery

  property :id,       Serial
  property :node,     Integer, min: 0, max: 2**32
  property :degree,   Integer
  property :value,    Float
  property :monitor,  Float
end 
