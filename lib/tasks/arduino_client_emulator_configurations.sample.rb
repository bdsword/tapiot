namespace :arduino_client do
  class ArduinoClientEmulatorConfigurations
    attr_accessor :port, :host, :rfid, :tap_id
    def initialize
      @port= ARDUINO-SERVER-PORT
      @host= 'ARDUINO-SERVER-HOST'
      @rfid= 'YOUR-RFID'
      @tap_id= YOUR-TAP-ID
    end
  end
end
