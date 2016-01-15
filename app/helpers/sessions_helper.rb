module SessionsHelper
	#this helper allow multiple controller & views
	#to use functions in this helper

	#Logs in the given user
	#this session method is defined by rails
	#the session created is encrypted
	def log_in(user)
		session[:user_id] = user.id
	end

	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end

	def logged_in?
		!current_user.nil?
	end
end
