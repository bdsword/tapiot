class UsersController < ApplicationController
  respond_to :html

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])

    @search = WaterUse.search(params[:q])
    @water_uses = @search.result.where(user_id: params[:id]).where.not(water_consumed: nil).page(params[:page]).per(15)

    respond_with @user
  end
end
