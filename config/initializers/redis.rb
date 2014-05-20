$ip = '127.11.185.2'
$port = 16379
if Rails.env.development?
    $ip = 'localhost'
    $port = 6379
end
r = Redis.new(:host => $ip , :port => $port )
$redis = Redis::Namespace.new(:logs,redis: r)
$resource = Redis::Namespace.new(:resource,redis: r)
