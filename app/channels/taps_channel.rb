class TapsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'taps'
  end
end
