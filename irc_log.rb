#require 'redis'
#require 'cinch'
#require 'sanitize'
require 'rubygems'
require 'bundler'
Bundler.require(:bot)
#127.11.185.2 -p 16379

redis = Redis.new(:host => '127.11.185.2', :port => 16379) #This is for development
# redis = Redis::new(:path=>"#{ENV['OPENSHIFT_GEAR_DIR']}tmp/redis.sock") #This is for production

#================================================This is the code of the bot ===================================

$channels_to_be_tracked = ["#nitk-autobotz"]
time = Time.now.localtime("+05:30")
$key = time.day.to_s + "-" + time.month.to_s + "-" + time.year.to_s
class Logger

  attr_accessor :redis
on 
  def initialize(ip,port) 
    #@redis = Redis.new(:host => ip, :port => port) #This is for development
     @redis = Redis.new(:host => '127.11.185.2', :port => 16379)
    #@redis = Redis::new(:path=>"#{ENV['OPENSHIFT_GEAR_DIR']}tmp/redis.sock") #This is for production
  end

  def get_time
    Time.now.localtime("+05:30")
  end

  def get_log_time
    t = get_time
    "#{t.hour}:#{t.min}"
    end
  end

  def log(channel,user,msg)
    nick = Sanitize.clean(user.nick)
    @redis.RPUSH "#{$key}", "<#{get_log_time}>"+"#{nick}"+":"+Sanitize.clean(msg)
  end

  def bot_log(channel,msg)    
    @redis.RPUSH "#{$key}", "<#{get_log_time}>" + "autobotz"+ ":"+ msg
  end

end


bot = Cinch::Bot.new do
  logger = Logger.new('127.0.0.1',6379)
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = $channels_to_be_tracked
    c.nick = 'autobotz-Sushant'
  end


  on :message,"!users" do |m|
    names = "Users: "
    m.channel.users.each do |f|
      names += f[0].to_s+" "
    end
    m.reply("#{names}")
    logger.bot_log(m.channel,names)
  end

  on :message,"!user_count" do |m|
    names = "#{m.user.nick}: Total_Users: #{m.channel.users.count}"
    m.reply("#{names}")
    logger.bot_log(m.channel,names)
  end

  on :message,"!hello" do |m|
    msg = "Hello #{m.user.nick}"
    m.reply(msg)
    logger.bot_log(m.channel,msg)
  end

  on :message,"!log" do |m|
    msg = "#{m.user.nick} Log can be found at http://localhost:3000/#{$key}"
    m.reply(msg)
    logger.bot_log(m.channel,msg)
  end

  on :message do |m|
    logger.log(m.channel,m.user,(m.params[1]).to_s)
  end

end

job1 = fork do
	bot.start
end

#================================================This is the code of the bot ===================================




# get '/message' do
# 	channel = "#"+params[:channel].to_s
# 	date = params[:date].to_s
# 	puts channel
# 	puts date
# 	len=redis.LLEN "#{channel}:#{date}"
# 	data = ''
# 	if len == 0
# 		"<html><h3>Log not found</h3></html>"
# 	else
# 		data = redis.lrange("#{channel}:#{date}",0,len)
# 		data = data.reverse.join("<br />")
# 	end
# 	data
# end

# get '/:channel' do
# 	channel = params[:channel].to_s
# 	len = redis.LLEN "\##{channel}"
# 	puts "Here =============================================== #{len}"
# 	@data=" "
# 	c = redis.lrange("\##{channel}",0,len).each do |f|
# 		puts "inside"
# 		@data+="<a href=\" /message?channel=#{channel}&date=#{f}\">#{f}</a><br /><br />"
# 	end
# 	erb :index
# end

# get '/' do
# 	len = redis.LLEN "channels"
# 	puts len
# 	data=" "
# 	redis.lrange("channels",0,len).each do |f|
# 		data+="<a href=\" /#{f[1,f.length]}\">#{f}</a><br /><br />"
# 	end
# 	"<h3>Channels:</h3><br/><br/>"+data
# end
