# require './lib/sample.rb'
# require './lib/tag_counter'
# require 'logger'
# require 'dm-aggregates'
# log = Logger.new(STDOUT)
# log.level = Logger::INFO
# 
# DataMapper.setup(:default, ENV['DATABASE_URL'])
# DataMapper.auto_upgrade!

task :cron do
  log.info("Start summaries")
  
  summaries = repository(:default).adapter.select("SELECT COUNT(DISTINCT s.id) AS count, m.message_date AS date FROM samples AS s INNER JOIN messages AS m ON s.node = m.node GROUP BY date")
  summaries.each do |s|
    summary = Summary.first_or_new(date: s.date)
    summary.count = s.count
    summary.save
  end
  log.info("End summaries")
end

task :deploy_heroku do
  (1..8).each do |i|
    puts `git push --force git@heroku.com:cftp-#{"%02d" % i}.git hashtags:master`
  end
end

task :migrate_to_counts do
  log.info("Start migration")
  
  # log.info("Running hashtag migration")
  # 
  # hashtags = repository(:default).adapter.select("SELECT DISTINCT(hashtag) as hashtag from hashtags")
  # hashtags.each do |h|
  #   log.info("Processing hashtag #{h} -- Standard Counts")
  #   counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(node)) as count, hashtag_date as date from hashtags where hashtag = '#{h}' GROUP BY date")
  #   counts.each do |c|
  #     item = HashtagCount.new(hashtag: h, date: c.date, count: c.count)
  #     log.info(item)
  #     item.save
  #   end
  #   
  #   log.info("Processing hashtag #{h} -- MH Counts")
  #   counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(s.id)) as count, h.hashtag_date as date from samples AS s INNER JOIN hashtags AS h ON s.node = h.node where hashtag = '#{h}' GROUP BY date")
  #   counts.each do |c|
  #     item = HashtagMhCount.new(hashtag: h, date: c.date, count: c.count)
  #     log.info(item)
  #     item.save
  #   end
  # end
  #   
  # log.info("Running mention migration")
  # 
  # mentions = repository(:default).adapter.select("SELECT DISTINCT(mention) as mention from mentions")
  # mentions.each do |m|
  #   log.info("Processing mention #{m} -- Standard Counts")
  #   counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(node)) as count, mention_date as date from mentions where mention = '#{m}' GROUP BY date")
  #   counts.each do |c|
  #     item = MentionCount.new(mention: m, date: c.date, count: c.count)
  #     log.info(item)
  #     item.save
  #   end
  #   
  #   log.info("Processing mention #{m} -- MH Counts")
  #   counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(s.id)) as count, m.mention_date as date from samples AS s INNER JOIN mentions AS m ON s.node = m.node where mention = '#{m}' GROUP BY date")
  #   counts.each do |c|
  #     item = MentionMhCount.new(mention: m, date: c.date, count: c.count)
  #     log.info(item)
  #     item.save
  #   end
  # end
    
  log.info("Running message migration")
  
  log.info("Processing messages -- Standard Counts")
  counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(node)) as count, message_date as date from messages GROUP BY date")
  counts.each do |c|
    item = MessageCount.new(date: c.date, count: c.count)
    log.info(item)
    item.save
  end
    
  log.info("Processing messages -- MH Counts")
  counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(s.id)) as count, m.message_date as date from samples AS s INNER JOIN messages AS m ON s.node = m.node GROUP BY date")
  counts.each do |c|
    item = MessageMhCount.new(date: c.date, count: c.count)
    log.info(item)
    item.save
  end
  
  log.info("Hastag migation complete")
  
  log.info("End migration")
  
end

task :process_new_messages do
  log.info("Start")
  
  counter = TagCounter.new
  
  log.info("Processing hashtags")
  
  hashtags = UnprocessedHashtag.all
  
  hashtags.each do |h|
    counter.add(h.hashtag_date, h.hashtag, h.node)
    attrs = h.attributes
    attrs.delete(:id)
    Hashtag.create(attrs)    
    h.destroy
  end
  
  counter.each do |date, tag, nodes|
    hashtag_count = HashtagCount.first_or_new(date: date, hashtag: tag)
    hashtag_count.count = nodes.count
    hashtag_mh_count = HashtagMhCount.first_or_new(date: date, hashtag: tag)
    hashtag_mh_count.count = Sample.count(node: nodes.to_a)
    hashtag_count.save
    hashtag_mh_count.save
  end
  
    
  log.info("Processing mentions")
  mentions = UnprocessedMention.all
  
  mentions.each do |m|
    counter.add(m.mention_date, m.mention, m.node)
    attrs = m.attributes
    attrs.delete(:id)
    Mention.create(attrs)    
    m.destroy
  end
  
  counter.each do |date, tag, nodes|
    mention_count = MentionCount.first_or_new(date: date, mention: tag)
    mention_count.count = nodes.count
    mention_mh_count = MentionMhCount.first_or_new(date: date, mention: tag)
    mention_mh_count.count = Sample.count(node: nodes.to_a)
    mention_count.save
    mention_mh_count.save
  end
      
  log.info("Processing messages")
  messages = UnprocessedMessage.all
  
  messages.each do |m|
    counter.add(m.message_date, 'message', m.node)
    attrs = m.attributes
    attrs.delete(:id)
    Message.create(attrs)    
    m.destroy
  end
  
  counter.each do |date, tag, nodes|
    message_count = MessageCount.first_or_new(date: date)
    message_count.count = nodes.count
    message_mh_count = MentionMhCount.first_or_new(date: date)
    message_mh_count.count = Sample.count(node: nodes.to_a)
    message_count.save
    message_mh_count.save
  end
  
  log.info("End end")
  
end