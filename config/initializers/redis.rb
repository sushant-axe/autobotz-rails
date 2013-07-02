require 'redis'
#$redis = Redis.new(:host => 'localhost', :port => 6379) for development
$redis = Redis.new(:host => '127.11.185.2', :port => 16379) #for production