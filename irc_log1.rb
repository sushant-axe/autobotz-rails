#require 'redis'
#require 'cinch'
#require 'sanitize'
require 'rubygems'
require 'bundler'
Bundler.require(:bot)
#127.11.185.2 -p 16379

#================================================This is the code of the bot ===================================

$channels_to_be_tracked = ["#testing-Joker"]
bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = $channels_to_be_tracked
    c.nick = 'autobotz-Megatron XD'
  end

  on :message, "!stop" do |m|
    m.reply("Snap! ..... I need to stop this dont I?")
  end

  on :message, "!log" do |m|
    m.reply("!log")
  end

end
job1 = fork do
	bot.start
end
