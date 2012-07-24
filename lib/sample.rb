require 'data_mapper'
require 'dm-chunked_query'
require 'dm-timestamps'

class Sample
  include DataMapper::Resource 
  include DataMapper::ChunkedQuery
  
  property :id,       Serial
  property :node,     Integer, min: 0, max: 2**32
  property :degree,   Integer
  property :value,    Float
  property :monitor,  Float
  property :created_at, DateTime
end 

class Hashtag
  include DataMapper::Resource
  
  property :id, Serial
  property :node, Integer, min: 0, max: 2**32
  property :message_id, Integer, min: 0, max: 2**64
  property :hashtag, String
  property :created_at, DateTime
  property :hashtag_time, DateTime
end