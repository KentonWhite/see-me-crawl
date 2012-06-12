crontab -r
crontab ./cron.txt
unbuffer ruby ./twitter_crawler.rb >> log.txt &