require './lib/twitter_node.rb' 

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
    statuses.each do |s|
      if s.text =~ @@hashtag_regex then
        puts "hashtag found"
        puts s.text
        return 1
      end
    end
    puts "hashtag not found"
    return 0
  end
end