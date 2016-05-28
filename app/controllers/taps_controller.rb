class TapsController < ApplicationController
  respond_to :html

  def index
    @taps = Tap.all
    respond_with @taps
  end

  def show
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

  end
end
