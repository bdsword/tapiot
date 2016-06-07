class DashboardController < ApplicationController
  respond_to :html

  before_action :authenticate_user!

  def show
    @search = WaterUse.search(params[:q])
    @user_monthly_water_uses = @search.result.where(user_id: current_user.id, created_at: (Time.now - 1.month)..Time.now)

    @top10_used_count_water_uses = @search.result.group(:tap_id).order('COUNT(id) DESC').limit(10).count(:id)
    @top10_tap_water_water_uses = @search.result.group(:tap_id).order('SUM(water_consumed) DESC').limit(10).sum(:water_consumed)

    @top10_water_uses = @search.result.order(water_consumed: :desc).limit(10)

    @system_monthly_water_uses = @search.result.where(created_at: (Time.now - 1.month)..Time.now)
  end
end
