require 'data_mapper'
require 'dm-chunked_query'
require 'dm-timestamps'

class Sample
  include DataMapper::Resource 
  include DataMapper::ChunkedQuery
  
  property :id,       Serial
  property :node,     Integer, min: 0, max: 2**32, index: true
  property :degree,   Integer
  property :value,    Float
  property :monitor,  Float
  property :created_at, DateTime
end 

class Hashtag
  include DataMapper::Resource
  
  property :id, Serial
  property :node, Integer, min: 0, max: 2**32, index: true
  property :message_id, Integer, min: 0, max: 2**64-1
  property :hashtag, String, index: true
  property :created_at, DateTime
  property :hashtag_time, DateTime
  property :hashtag_date, Date, index: true
end

class Mention
  include DataMapper::Resource
  
  property :id, Serial
  property :node, Integer, min: 0, max: 2**32, index: true
  property :message_id, Integer, min: 0, max: 2**64-1
  property :mention, String, index: true
  property :created_at, DateTime
  property :mention_time, DateTime
  property :mention_date, Date, index: true
end

class Message
  include DataMapper::Resource

  property :id, Integer, min: 0, max: 2**64-1, key: true, unique: true
  property :node, Integer, min: 0, max: 2**32, index: true
  property :created_at, DateTime
  property :message_time, DateTime  
  property :message_date, Date, index: true  
end
