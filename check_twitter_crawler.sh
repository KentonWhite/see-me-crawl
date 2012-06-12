ruby_job=`ps aux | grep ruby | grep -v grep`
echo $ruby_job
if [ "$ruby_job" == '' ]
	then
	`./start_twitter_crawler.sh`
fi