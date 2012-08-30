require './lib/sample.rb'
require 'logger'
log = Logger.new(STDOUT)
log.level = Logger::INFO

DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
DataMapper.auto_upgrade!

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

task :migrate_to_counts do
  log.info("Start migration")
  
  log.info("Running hashtag migration")
  
  hashtags = repository(:default).adapter.select("SELECT DISTINCT(hashtag) as hashtag from hashtags")
  hashtags.each do |h|
    log.info("Processing hashtag #{h} -- Standard Counts")
    counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(node)) as count, hashtag_date as date from hashtags where hashtag = '#{h}' GROUP BY date")
    counts.each do |c|
      item = HashtagCount.new(hashtag: h, date: c.date, count: c.count)
      log.info(item)
      item.save
    end
    
    log.info("Processing hashtag #{h} -- MH Counts")
    counts = repository(:default).adapter.select("SELECT COUNT(DISTINCT(s.id)) as count, h.hashtag_date as date from samples AS s INNER JOIN hashtags AS h ON s.node = h.node where hashtag = '#{h}' GROUP BY date")
    counts.each do |c|
      item = HashtagMhCount.new(hashtag: h, date: c.date, count: c.count)
      log.info(item)
      item.save
    end
    
  end 
  
  log.info("Hastag migation complete")
  
  log.info("End migration")
  
end