require './lib/base_node.rb' 
require 'twitter'
require 'active_support/inflector'
require 'yaml'

class TwitterNode < BaseNode
  def initialize(id)
    super(id)
    if !populated? || stale?(visited_at)
      populate_from_twitter
      save!
    end
  end
  
  def crawl! 
    return if private? || !stale?(crawled_at) 
    friends = fetch(:friends)
    followers = fetch(:followers)
    update_edges(friends: friends, followers: followers)
    @crawled_at = DateTime.now
    save!
  end
  
  def fetch(type) 
    cursor = -1
    nodes = []
    until cursor == 0
      begin
        result = client.send("#{type.to_s.singularize}_ids", id, cursor: cursor)
      rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError => e 
        p e.message
        retry
      end
      nodes += result.ids
      cursor = result.next_cursor
    end
    nodes
  end
  
  private 
    
  def client
    puts "calling Twitter" 
    @client ||= new_client
    @client.sample
  end 
  
  def new_client
    accounts = YAML::load_file(File.dirname(__FILE__) + '/../config/twitter.yml')['clients']
    accounts.map do |account| 
      Twitter.configure do |config|
        config.consumer_key = account['consumer_key']
        config.consumer_secret = account['consumer_secret']
        config.oauth_token = account['oauth_token']
        config.oauth_token_secret = account['oauth_token_secret']
      end 
      Twitter::Client.new
    end
  end
  
  def populate_from_twitter
    begin
      user = client.user(id) 
      @in_degree = user.followers_count
      @out_degree = user.friends_count
      @private = user.protected
    rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError => e 
      p e.message
      retry
    rescue Twitter::Forbidden, Twitter::NotFound  => e
      p e.message
      @in_degree = 0
      @out_degree = 0
      @private = true
    end
    @populated = true
    user      
  end

end