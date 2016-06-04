class TapsController < ApplicationController
  respond_to :html

  protect_from_forgery except: [:turn_on, :turn_off]

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

  def turn_on
    @tap = Tap.find(params[:id])
    @user = User.find_by_rfid(params[:rfid])

    if @tap!=nil && @user!=nil
      # create a record in water_uses
      @water_use = WaterUse.new(:tap_id => @tap.id, :user_id => @user.id)
      @water_use.save!

      respond_to do |format|
        format.json { render text: "1 #{@water_use.id}" }
      end
    else
      respond_to do |format|
        format.json { render text: '0' }
      end
    end
  end

  def turn_off
    @tap = Tap.find(params[:id])
    @user = User.find_by_rfid(params[:rfid])

    if @tap!=nil && @user!=nil
      respond_to do |format|
        format.json { render text: '1' }
      end

      # update record in water_uses
      @water_use = WaterUse.find(params[:record_id])
      @water_use.update(:water_consumed => params[:water_used])
    else
      respond_to do |format|
        format.json { render text: '0' }
      end
    end
  end

  private

  def tap_params
    params.require(:tap).permit(:location, :created_at, :updated_at)
  end
end
