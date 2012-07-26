require './lib/twitter_node.rb'
# require './lib/sample.rb' 

class HashtagTwitterNode < TwitterNode
  
  @@hashtag_regex = /#/i

  def hashtag?
    @hashtag ||= check_hashtag
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
    messages = Hashtag.all(node: id, fields: [:message_id]).map { |m| m.message_id }
    statuses.each do |s|
      next if messages.include? s.id
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