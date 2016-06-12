class WaterUsesController < ApplicationController
  respond_to :html

  before_action :authenticate_user!

  def index
    @search = WaterUse.search(params[:q])
    @water_uses = @search.result.where(user_id: current_user.id).where.not(water_consumed: nil)

    @total_pulses = 0
    @total_time = 0
    @water_uses.each do |water_use|
        @total_pulses += water_use.water_consumed
        @total_time += (water_use.updated_at - water_use.created_at)
    end

    @water_uses = @search.result.where(user_id: current_user.id).where.not(water_consumed: nil).page(params[:page]).per(10)

    respond_with @water_uses
  end

  def search
    index
    render :index
  end
end
