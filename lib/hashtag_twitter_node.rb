require './lib/twitter_node.rb'
require 'active_support/core_ext'
# require './lib/sample.rb' 

class HashtagTwitterNode < TwitterNode
  
  @@hashtag_regex = /#/i

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
      DataMapper.repository(:local) do
        begin
          UnprocessedMessage.create(id: s.id, node: id, message_time: s.created_at, message_date: s.created_at.to_date)
        rescue DataObjects::SQLError => e
          p e.message
          retry
        end
      end
      if s.text =~ @@hashtag_regex then
        hashtag_found = 1
      end
      hastags = s.text.scan(/[#]\w+/i)
      hastags.each do |h|
        DataMapper.repository(:local) do
          UnprocessedHashtag.create(node: id, message_id: s.id, hashtag: h.downcase, hashtag_time: s.created_at, hashtag_date: s.created_at.to_date)
        end
      end
      mentions = s.text.scan(/[\@]\w+/i)
      mentions.each do |m|
        DataMapper.repository(:local) do
          UnprocessedMention.create(node: id, message_id: s.id, mention: m.downcase, mention_time: s.created_at, mention_date: s.created_at.to_date)
        end
      end
    end
    return hashtag_found
  end
end