require 'data_mapper'

class BaseSample
  include DataMapper::Resource 

  property :id,       Serial
  property :node,     Integer, min: 0, max: 2**32
  property :value,    Float
  property :monitor,  Float
end 
