require './lib/base_node.rb' 
require 'twitter'
require 'chronic'

class TwitterNode < BaseNode
  def initialize(id)
    super(id)
    Twitter.configure do |config|
      config.oauth_token = "140442120-yoNDd54g5djiWwaX1EJObNHo48L3Et0XXc1eCXW9"
      config.oauth_token_secret = "VlDMtXoI7TmvC7lBlHVpEJxkUlvTnux3AidEh0qiI"
      config.consumer_key = "vu2ILfmWPptGVZzcFQtzIA"
      config.consumer_secret = "PS5JZqQSNlCa4tlNpFAACdVTQlGJw8FnnUFqQY8M9eo"
    end
    @client = Twitter::Client.new 
    if !populated? || visited_at < Chronic.parse('1 week ago').to_datetime
      populate_from_twitter
    end
  end
  
  def crawl!
    friends = fetch(:friends)
    followers = fetch(:followers)
    update_edges(friends: friends, followers: followers)
  end
  
  def fetch(type)

  end
  
  private
  
  def populate_from_twitter
    begin
      user = @client.user(id) 
      @in_degree = user.followers_count
      @out_degree = user.friends_count
      @private = false
    rescue Twitter::Unauthorized => e
      @private = true
    rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest => e 
      p e.message
      retry
    end
    save!
    @populated = true      
  end

end