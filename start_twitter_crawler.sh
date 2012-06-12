crontab -r
crontab /home/ubuntu/see-me-crawl/cron.txt
unbuffer ruby /home/ubuntu/see-me-crawl/twitter_crawler.rb >> log.txt &