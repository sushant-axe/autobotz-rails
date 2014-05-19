#require 'redis'
#require 'cinch'
#require 'sanitize'
require 'rubygems'
require 'bundler'
Bundler.require(:bot)
#127.11.185.2 -p 16379

redis = Redis.new(:host => '127.11.185.2', :port => 16379) #This is for development
#================================================This is the code of the bot ===================================

$channels_to_be_tracked = ["#nitk-agile-dev"]
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
    temp = get_time.day.to_s + "-" + get_time.month.to_s + "-" +get_time.year.to_s
    if(temp != $key )
      $key = temp
    end
    nick = Sanitize.clean(user.nick)
    @redis.RPUSH "#{$key}", "<#{get_log_time}>"+"#{nick}"+":"+Sanitize.clean(msg)
  end

  def bot_log(channel,msg)
    temp = get_time.day.to_s + "-" + get_time.month.to_s + "-" +get_time.year.to_s
    if(temp != $key)
      $key = temp
    end
    @redis.RPUSH "#{$key}", "<#{get_log_time}>" + "Autobotz-JetFire"+ ":"+ msg
  end

end
$bot = Cinch::Bot.new do
  logger = Logger.new('127.0.0.1',6379)
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = $channels_to_be_tracked
    c.nick = 'autobotz-JetFire'
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

  on :message do |m|
    logger.log(m.channel,m.user,(m.params[1]).to_s)
  end

end


class RunBotController < ApplicationController


def run
t1 = Thread.new{$bot.start}
end
end
