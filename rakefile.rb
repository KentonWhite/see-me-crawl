require './lib/sample.rb'
require 'logger'
log = Logger.new(STDOUT)
log.level = Logger::INFO
task :cron do
  log.info("Start summaries")
  DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
  summaries = repository(:default).adapter.select("SELECT COUNT(DISTINCT s.id) AS count, m.message_date AS date FROM samples AS s INNER JOIN messages AS m ON s.node = m.node GROUP BY date")
  summaries.each do |s|
    Summary.first_or_create(date: s.date, )
  end
  log.info("End summaries")
end