ruby_job=`ps aux | grep ruby | grep -v grep`
[ -z "$run_job" ] && `/home/ubuntu/see-me-crawl/start_twitter_crawler.sh`
