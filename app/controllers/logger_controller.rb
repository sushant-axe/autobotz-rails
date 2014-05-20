class LoggerController < ApplicationController

	def home
	end

	def logs
		@logs = $redis.keys
		@logs = @logs.reverse
	end
	def resources
		len = $resource.LLEN("resource")
		@resources = $resource.lrange("resource",0,len).uniq!
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
