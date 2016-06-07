class DashboardController < ApplicationController
  respond_to :html

  before_action :authenticate_user!

  def show
    @search = WaterUse.search(params[:q])
    @water_uses_1 = @search.result.where(user_id: current_user.id, created_at: (Time.now - 1.month)..Time.now)

    @water_uses_2 = @search.result.group(:tap_id).order('COUNT(id) DESC').count(:id)
    @water_uses_3 = @search.result.group(:tap_id).order('SUM(water_consumed) DESC').sum(:water_consumed)

    @water_uses_4 = @search.result.order(water_consumed: :desc).limit(10)

    @water_uses_5 = @search.result.where(created_at: (Time.now - 1.month)..Time.now)
  end
end
