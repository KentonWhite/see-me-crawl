require './lib/twitter_node'
require 'hashie'

class TwitterCityNode < TwitterNode

  @@city = 'ottawa'
  
  def initialize(id)
    user = super(id)
    p user.location if user.respond_to?(:location)
  end
  
  def fetch(type)
   nodes = super(type)
   filtered_nodes = []
   nodes.each_slice(100) do |n|
     users = client.users(n)
     users.keep_if { |u| u.location =~ /#{@@city}/i }
     filtered_nodes.concat users.map { |u| u.id }
   end 
   filtered_nodes 
  end
end