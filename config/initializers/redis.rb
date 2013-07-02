require 'redis'
#$redis = Redis.new(:host => 'localhost', :port => 6379) for development
$redis = Redis.new(:host => '127.3.164.1', :port => 15008) #for production