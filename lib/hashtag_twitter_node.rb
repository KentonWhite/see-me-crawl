require './lib/twitter_node.rb'
# require './lib/sample.rb' 

class HashtagTwitterNode < TwitterNode
  
  @@hashtag_regex = /#/i

  def hashtag?
    @hastag ||= check_hashtag
  end
  
  private
  
  def check_hashtag
    puts "Checking for hashtag...."
    begin
      statuses = client.user_timeline(id, :count  => 200, :include_rts => true)
    rescue Twitter::ServiceUnavailable, Errno::ECONNRESET, Twitter::BadGateway, Twitter::BadRequest, Twitter::InternalServerError, OpenSSL::SSL::SSLError, SocketError, EOFError, Zlib::GzipFile::Error => e 
      p e.message
      retry
    end
    hashtag_found = 0
    statuses.each do |s|
      if s.text =~ @@hashtag_regex then
        puts "hashtag found"
        puts s.text
        hashtag_found = 1
      end
      hastags = s.text.scan(/#\w+/i)
      hastags.each do |h|
        DataMapper.repository(:local) do
          Hashtag.create(node: id, message_id: s.id, hashtag: h.downcase, hashtag_time: s.created_at)
        end
      end
    end
    return hashtag_found
  end
end