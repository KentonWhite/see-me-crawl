require 'data_mapper'

DataMapper.setup(:default, 
  adapter:    'simpledb',
  access_key: 'AKIAJOOPW5QN4DZJG2BA',
  secret_key: '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',
  domain:     'gertrude-stein-tw'
)

class Node
  include DataMapper::Resource

  property :id,         Integer, :min => 0, :max => 2**32, :key => true
  property :in_degree,  Integer
  property :out_degree, Integer
  property :visited_at, DateTime
  property :private,    Boolean,  :default => false 
end