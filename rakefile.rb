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
  
  Hashtag.each_chunk(100) do |hashtags|
    hashtags.each do |h|
      item = HashtagCount.first_or_new({hashtag: h.hashtag, date: h.hashtag_date}, {count: 0})
      item.count += 1
      log.info(item)
      item.save 
      
      item = HashtagMhCount.first_or_new({hashtag: h.hashtag, date: h.hashtag_date}, {count: 0})
      mh_count = repository(:default).adapter.select("select count(distinct s.id) as count from samples as s inner join hashtags as h on s.node = h.node where h.hashtag = '#{h.hashtag}'")
      item.count += 1
      log.info(item)
      item.save 
    end
  end 
  
  log.info("Hastag migation complete")
  
  log.info("End migration")
  
end