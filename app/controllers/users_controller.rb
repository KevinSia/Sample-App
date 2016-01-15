class UsersController < ApplicationController
	 
  def show
  	@user = User.find(params[:id])
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      log_in @user #defined in sessions helper
      flash[:success] = "Welcome to the Sample App!"
  		redirect_to @user
  	else
  		render 'new'
  	end
  end



  #to avoid mass assignment that can be done using command line HTTP client
  #private keeps method from exposing to external users (used internally by Users)
  #example : admin access 
  private
  	def user_params
  		params.require(:user).permit(:name,:email,:password,:password_confirmation)
  	end
end
