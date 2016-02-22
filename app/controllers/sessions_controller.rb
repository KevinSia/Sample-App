class SessionsController < ApplicationController
  def new
  end

  # if user get auto redirected to new by other pages
  #  redirect_to session[:forwarding_url]
  # else if user goes to new manually
  #  redirect_to @user
  def create
  	@user = User.find_by(email: params[:session][:email].downcase)

  	if @user && @user.authenticate(params[:session][:password])
  		log_in @user  #defined in sessions helper
      params[:session][:remember_me] == '1'? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
  		render 'new'
  	end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
