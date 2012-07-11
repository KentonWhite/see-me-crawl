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
     begin
       users = client.users(n)
     rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError => e 
       p e.message
       retry
     end
     users.keep_if { |u| u.location =~ /#{@@city}/i }
     filtered_nodes.concat users.map { |u| u.id }
   end 
   filtered_nodes 
  end
end