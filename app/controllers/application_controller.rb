class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  # stores location before a non-user is redirected
  def require_login?
    unless logged_in?
      store_location
      flash[:danger] = "Please log in to access this page."
      redirect_to login_url
    end
  end

end
