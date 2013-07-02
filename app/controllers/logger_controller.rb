class LoggerController < ApplicationController

	def home
		@logs = $redis.keys
	end
	def show
		len = $redis.LLEN(params[:key])
		@date = params[:key]
		@messages = $redis.lrange(params[:key],0,len)
		if @messages.nil?
			flash[:notice] = "An Error Occurred while processing your request : Record not found!"
		end
	end
end
