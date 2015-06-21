#require 'redis'
#require 'cinch'
#require 'sanitize'
require 'rubygems'
require 'bundler'
Bundler.require(:bot)
#127.11.185.2 -p 16379

redis = Redis.new(:host => '127.11.185.2', :port => 16379) #This is for development
#================================================This is the code of the bot ===================================

$channels_to_be_tracked = ["#nitk-ectf"]
time = Time.now.localtime("+05:30")
$key = time.day.to_s + "-" + time.month.to_s + "-" + time.year.to_s
class Logger

  attr_accessor :redis

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

  def setkey
    $key = time.day.to_s + "-" + time.month.to_s + "-" + time.year.to_s
  end

  def log(channel,user,msg)
    temp = Time.now.day.to_s + "-" + Time.now.month.to_s + "-" + Time.now.year.to_s
    if(temp != $key )
      $key = temp
    end
    nick = Sanitize.clean(user.nick)
    @redis.RPUSH "#{$key}", "<#{get_log_time}>"+"#{nick}"+":"+Sanitize.clean(msg)
  end

  def bot_log(channel,msg)
    temp = Time.now.day.to_s + "-" + Time.now.month.to_s + "-" + Time.now.year.to_s
    if(temp != $key)
      $key = temp
    end
    @redis.RPUSH "#{$key}", "<#{get_log_time}>" + "autobotz"+ ":"+ msg
  end

end


bot = Cinch::Bot.new do
  logger = Logger.new('127.0.0.1',6379)
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = $channels_to_be_tracked
    c.nick = 'Rusty'
  end

  @users = nil

  on :message,"!commands" do |m|
    message = "Available commands: !commands !users !user_count !hello !log !resources !ping_all !pong !r. Additional: #resource <link> - To add a Resource."
    m.reply(message)
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
    msg = "#{m.user.nick} Log can be found at http://autobotz-sushant94.rhcloud.com/#{$key}"
    m.reply(msg)
    logger.bot_log(m.channel,msg)
  end

  on :message,"!resources" do |m|
    msg = "#{m.user.nick} Resources can be found at http://autobotz-sushant94.rhcloud.com/logger/resources"
    m.reply(msg)
    logger.bot_log(m.channel,msg)
  end

  on :message do |m|
    logger.log(m.channel,m.user,(m.params[1]).to_s)
  end

  on :message,"!start" do |m|
  end

  on :message,"!stop" do |m|
  end

  on :message,"!comic" do |m|
    num = rand(1 .. 1370)
    msg = "#{m.user.nick}, lighten up! Here's a comic ==>  https://xkcd.com/#{num}/"
    m.reply(msg)
    logger.bot_log(m.channel,msg)
  end

  on :message, /^#resource (.+)$/ do |m,r|
  logger.log(m.channel,m.user,(m.params[1]).to_s)
  if r =~ /^#{URI::regexp(['http', 'https'])}$/
    $resource.RPUSH "resource",r.to_s
    m.reply("Resource added")
  else
    m.reply("Invalid URI")
  end
end

on :message, /^tell me everything about (.+)$/ do |m, target|
  user = User(target)
  m.reply "%s is named %s and connects from %s" % [user.nick, user.name, user.host]
end

on :message,"!ping_all" do |m|
  @users = m.channel.users
  m.channel.users.each do |f|
    f[0].msg("ping! Respond with !pong to confirm presence.")
  end
  m.reply("!pong")
end

 on :message,"!tales" do |m|
  num=rand(1..29)
  msg="140 character tales,but depict a thousand words.Food for thought #{m.user.nick} --> http://terriblytinytales.com/category/seasons/season-#{num}"
  m.reply(msg)
  logger.bot_log(m.channel,msg)
end
on :message, "!pong" do |m|
  unless @users.nil?
    @users.delete(m.user)
  end
end

on :message,"!r" do |m|
  if @users && !@users.empty?
    message = "unconfirmed users: "
    @users.each do |f|
      message+= f[0].to_s  + " "
    end
    m.reply(message)
  else
    m.reply("All confirmed!")
  end
end

end

job1 = fork do
	bot.start
end
