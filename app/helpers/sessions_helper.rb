module SessionsHelper
	#this helper allow multiple controller & views
	#to use functions in this helper

	#Logs in the given user
	#this session method is defined by rails
	#the session created is encrypted
	def log_in(user)
		session[:user_id] = user.id
	end

	#remembers user in a persistent session
	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end


	# Scenario:
	# if user is in session
	#   set user to @current_user with session[:user_id]
	# elsif user is using cookies
	#   check user cookie's remember token
	#   if token matches database
	#     set user to @current_user with cookie.signed[:user_id]

	def current_user
		if (user_id = session[:user_id])
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id]) # when user closes browser session expires
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user # user who comes with cookie does not need to go login page
				@current_user = user
			end
		end
	end

	def current_user?(user)
		user == current_user
	end

	def logged_in?
		!current_user.nil?
	end

	def log_out
		forget @current_user
		session.delete(:user_id)
		@current_user = nil
	end

	# session.delete occurs first
	# because redirect_to only executes after return
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# only store url for a get request
	# redirect_to sends get request
	def store_location
		session[:forwarding_url] = request.url if request.get?
	end


end
