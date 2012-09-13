unbuffer ruby ./process_node.rb >> log.txt &
unbuffer ruby ./process_new_messages.rb >> log.txt &
unbuffer ruby ./process_new_mentions.rb >> log.txt &
unbuffer ruby ./process_new_hashtags.rb >> log.txt &
unbuffer ruby ./twitter_crawler.rb --memcached >> log.txt &
