class MicropostsController < ApplicationController
  before_action :require_login?, only: [:create, :destroy]
  before_action :correct_user?, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url # refreshes page
    else
      @feed_items = []
      render 'static_pages/home' # render without params / x through controller
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted successfully!"
    redirect_to request.referrer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def correct_user?
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end
end
