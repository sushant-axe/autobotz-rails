require File.expand_path('../boot', __FILE__)

require 'rails/all'
t1 = Thread.new
{
    #require 'redis'
#require 'cinch'
#require 'sanitize'
require 'rubygems'
require 'bundler'
Bundler.require(:bot)
#127.11.185.2 -p 16379

redis = Redis.new(:host => '127.11.185.2', :port => 16379) #This is for development
#================================================This is the code of the bot ===================================

$channels_to_be_tracked = ["#nitk-autobotz"]
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

job1 = fork do
    bot.start
end
}

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Autobotz
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
