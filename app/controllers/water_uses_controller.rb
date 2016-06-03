class WaterUsesController < ApplicationController
  respond_to :html

  def index
    # list user's records
  end

  def show
    # show record detail
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
    @water_use = WaterUse.find(params[:id])
    @water_use.destroy

    redirect_to :action => :index
  end
end
