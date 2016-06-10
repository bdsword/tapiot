class TapsController < ApplicationController
  respond_to :html

  protect_from_forgery except: [:turn_on, :turn_off]

  # TODO: :turn_on and :turn_off should be handle by another authenticate method
  before_action :authenticate_user!, except: [:index, :show, :turn_on, :turn_off, :web_turn_off_update]
  before_action only: [:new, :edit, :create, :update, :destroy] do
    render(file: 'public/403.html', status: :forbidden, layout: false) unless current_user.admin?
  end

  def index
    @search = Tap.search(params[:q])
    @taps = @search.result.page(params[:page]).per(15)
    @in_use_taps = WaterUse.where(water_consumed: nil).pluck(:tap_id)
    respond_with @taps
  end

  def show
    @tap = Tap.find(params[:id])

    @search = WaterUse.search(params[:q])
    @water_uses = @search.result.where(tap_id: params[:id]).where.not(water_consumed: nil).page(params[:page]).per(15)

    respond_with @tap
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

    if @tap.present? && @user.present?
      # create a record in water_uses
      @water_use = WaterUse.new(tap_id: @tap.id, user_id: @user.id)
      @water_use.save!

      ActionCable.server.broadcast 'taps', {tap_id: @tap.id, state: 1}
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
    @user = User.find_by_rfid(params[:rfid])
    @water_use = WaterUse.find_by(id: params[:record_id], user_id: @user.id, tap_id: params[:id])

    if @water_use.present?
      # update record in water_uses
      @water_use.update(water_consumed: params[:water_used])

      ActionCable.server.broadcast 'taps', {tap_id: @water_use.tap_id, state: 0}
      respond_to do |format|
        format.json { render text: '1' }
      end
    else
      respond_to do |format|
        format.json { render text: '0' }
      end
    end
  end

  def web_turn_on
    @tap = Tap.find(params[:id])

    if @tap.present?
      if WaterUse.exists?(tap_id: @tap.id, water_consumed: nil)
        # User should not reach here
        flash[:alert] = 'The tap is in use!'
      else
        @water_use = WaterUse.new(tap_id: @tap.id, user_id: current_user.id)
        @water_use.save!
        Redis.new.publish(:website_active_queue, {action: 1, tap_id: @tap.id, record_id: @water_use.id})
        flash[:notice] = 'Turn on success!'
        ActionCable.server.broadcast 'taps', {tap_id: @tap.id, state: 1}
      end
    else
      flash[:alert] = 'The tap does not exist!'
    end
    redirect_to action: :index
  end

  def web_turn_off
    @tap = Tap.find(params[:id])

    if @tap.present?
      @water_use = WaterUse.find_by(tap_id: @tap.id, water_consumed: nil)
      if @water_use.present?
        if @water_use.user_id == current_user.id
          @water_use.turn_off_token = SecureRandom.base64(128)
          @water_use.save!
          Redis.new.publish(:website_active_queue, {action: 0, tap_id: @tap.id,
                                                    turn_off_token: @water_use.turn_off_token})
          flash[:notice] = 'Turn off success!'
        else
          flash[:alert] = 'Only the user who turn on this tap is allowed to turn it off!'
        end
      else
        # User should not reach here
        flash[:alert] = 'The tap is not in use!'
      end
    else
      flash[:alert] = 'The tap does not exist!'
    end

    redirect_to action: :index
  end

  def web_turn_off_update
    @record = WaterUse.find_by(turn_off_token: params[:turn_off_token])

    if @record.present?
      @record.water_consumed = params[:water_used]
      @record.save!
      ActionCable.server.broadcast 'taps', {tap_id: @record.tap_id, state: 0}
    end
    head(:ok, content_type: 'text/html')
  end

  private

  def tap_params
    params.require(:tap).permit(:location, :created_at, :updated_at)
  end
end
