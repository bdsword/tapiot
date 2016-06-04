namespace :arduino_client do
  class ArduinoServerConfigurations
    attr_accessor :port, :host, :rails_host
    def initialize
      @port = YOUR-PORT
      @host = 'YOUR-HOST'
      @rails_host = 'YOUR-RAILS-HOST'
    end
  end
end
