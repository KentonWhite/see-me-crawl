ruby_job=`ps aux | grep ruby | grep -v grep`
echo $ruby_job
if [ "$ruby_job" == '' ]
	then
	`/home/ubuntu/see-me-crawl/start_twitter_crawler.sh`
fi