require './lib/twitter_node'
require 'hashie'

class TwitterCityNode < TwitterNode

  @@city = /toronto/i
  
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
     rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError, Zlib::GzipFile::Error => e 
       p client 
       p e.message
       retry
     end
     users.keep_if { |u| u.location =~ @@city }
     filtered_nodes.concat users.map { |u| u.id }
   end 
   filtered_nodes 
  end
end