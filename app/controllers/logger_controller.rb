class LoggerController < ApplicationController

	def home
		@logs = $redis.keys
	end
	def show
		logs = $redis.keys
		index = logs.find_index(params[:key])
		@next = nil
		@prev = nil
		@next = logs[index+1] unless (index == logs.length)
		@prev = logs[index-1] unless (index == 0)
		len = $redis.LLEN(params[:key])
		@date = params[:key]
		@messages = $redis.lrange(params[:key],0,len)
		if @messages.nil?
			flash[:notice] = "An Error Occurred while processing your request : Record not found!"
		end
	end
end
