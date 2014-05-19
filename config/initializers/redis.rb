require 'redis'
$ip = '127.11.185.2'
$port = 16379
# $ip = 'localhost'
# $port = 6379
#$redis = Redis.new(:host => 'localhost', :port => 6379) #for development
$redis = Redis.new(:host => $ip , :port => $port ) #for production
