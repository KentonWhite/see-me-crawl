require './lib/twitter_node.rb'
require 'active_support/core_ext'
# require './lib/sample.rb' 

class HashtagTwitterNode < TwitterNode
  
  attr_reader :messages, :hashtags, :mentions
    
  @@hashtag_regex = /#/i
  
  def initialize(id)
    super(id)
    @messages = []
    @hashtags = []
    @mentions = []
  end
  
  def hashtag?
    @hashtag ||= check_hashtag
  end
  
  def check_hashtag
    begin
      statuses = client.user_timeline(id, :count  => 200, :include_rts => true)
    rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError, Zlib::GzipFile::Error => e 
      p e.message
      retry
    end
    hashtag_found = 0
    statuses.each do |s|
      next if Message.count(id: s.id) > 0 || UnprocessedMessage.count(id: s.id) > 0
      begin
        m = Message.create(id: s.id, node: id, message_time: s.created_at, message_date: s.created_at.to_date)
      rescue DataObjects::SQLError => e
        p e.message
        retry
      end
      @messages << m
      if s.text =~ @@hashtag_regex then
        hashtag_found = 1
      end
      hastags = s.text.scan(/[#]\w+/i)
      hastags.each do |h|
        @hashtags << Hashtag.create(node: id, message_id: s.id, hashtag: h.downcase, hashtag_time: s.created_at, hashtag_date: s.created_at.to_date)
      end
      mentions = s.text.scan(/[\@]\w+/i)
      mentions.each do |m|
        @mentions << Mention.create(node: id, message_id: s.id, mention: m.downcase, mention_time: s.created_at, mention_date: s.created_at.to_date)
      end
    end
    return hashtag_found
  end
end