class TapsController < ApplicationController
  respond_to :html

  def index
    @taps = Tap.all
    respond_with @taps
  end

  def show
    @tap = Tap.find(params[:id])
  end

  def new
    @tap = Tap.new
  end

  def edit
    @tap = Tap.find(params[:id])
  end

  def create
    @tap = Tap.new(tap_params)
    @tap.save

    redirect_to :action => :index
  end

  def update
    @tap = Tap.find(params[:id])
    @tap.update(tap_params)

    redirect_to :action => :index
  end

  def destroy
    @tap = Tap.find(params[:id])
    @tap.destroy

    redirect_to :action => :index
  end

  private

  def tap_params
    params.require(:tap).permit(:location, :created_at)
  end
end
