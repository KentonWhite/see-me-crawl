require './lib/sample.rb'

task :cron do
  DataMapper.setup(:default, adapter: 'mysql', database: 'sample', user: 'root')
  summaries = repository(:default).adapter.select("SELECT COUNT(DISTINCT s.id) AS count, m.message_date AS date FROM samples AS s INNER JOIN messages AS m ON s.node = m.node GROUP BY date")
  p summaries
    
end