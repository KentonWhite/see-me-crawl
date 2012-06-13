require './lib/base_node.rb' 
require 'twitter'
require 'active_support/inflector'

class TwitterNode < BaseNode
  def initialize(id)
    super(id)
    if !populated? || stale?(visited_at)
      populate_from_twitter
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
      # rescue Twitter::Unauthorized => e
      #   p e.message
      #   # @private = true
      #   # save!
      #   return []
      rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, EOFError => e 
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
    clients = []
    Twitter.configure do |config|
      config.oauth_token = "140442120-yoNDd54g5djiWwaX1EJObNHo48L3Et0XXc1eCXW9"
      config.oauth_token_secret = "VlDMtXoI7TmvC7lBlHVpEJxkUlvTnux3AidEh0qiI"
      config.consumer_key = "vu2ILfmWPptGVZzcFQtzIA"
      config.consumer_secret = "PS5JZqQSNlCa4tlNpFAACdVTQlGJw8FnnUFqQY8M9eo"
    end

    clients << Twitter::Client.new

    Twitter.configure do |config|
      config.oauth_token = "57954581-TJBachPGM7Z6D92HZfRQ8qeRFqVgKTzgANMGq5pdN"
      config.oauth_token_secret = "2ubyhfuttgGp5cf8DOsSfQT0nF1Y5VsvW3vSS03k"
      config.consumer_key = "vu2ILfmWPptGVZzcFQtzIA"
      config.consumer_secret = "PS5JZqQSNlCa4tlNpFAACdVTQlGJw8FnnUFqQY8M9eo"
    end

    clients << Twitter::Client.new

    Twitter.configure do |config|
      config.oauth_token = "221467686-e1IbDn2sypx36XFvskscqkfpK1HOjwhaBDeGL4Mk"
      config.oauth_token_secret = "tVTVYGNx7XBWBWZjQM9KQ15kchi5zvCvw32cCTRRU"
      config.consumer_key = "cmN0crWAu4PjgyKvS6Now"
      config.consumer_secret = "pYSBMjhodiZr4wNjj8DqGCInuSSG8DfggTiOkTtI"
    end
    
    clients << Twitter::Client.new

    Twitter.configure do |config|
      config.oauth_token = "140442120-nqgveE7eIpLOSK7KsBAohGtamcboWUFFM7IoQ3lJ"
      config.oauth_token_secret = "u5gQ1gFYiyBopefD2EDGkGCKZam9Y1IQstjRm0bPi0"
      config.consumer_key = 'jbMfebvHBXGq0DzYNcqg'
      config.consumer_secret = 'JmdijQ1oJzUhohmcrA1saJyw5Ssb42lyFBTtA2aoqE'
    end
    
    clients << Twitter::Client.new
  end
  
  def populate_from_twitter
    begin
      user = client.user(id) 
      @in_degree = user.followers_count
      @out_degree = user.friends_count
      @private = user.protected
    # rescue Twitter::Unauthorized => e 
    #   p e.message
    #   @private = true
    rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, SocketError, EOFError => e 
      p e.message
      retry
    rescue Twitter::Forbidden => e
      p e.message
      @in_degree = 0
      @out_degree = 0
      @private = true
    end
    save!
    @populated = true      
  end

end