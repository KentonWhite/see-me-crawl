unbuffer ruby ./twitter_crawler.rb --memcached >> log.txt &
unbuffer ruby ./process_new_messages.rb >> log.txt &