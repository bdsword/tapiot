require 'socket'
require 'net/http'
require 'tasks/arduino_server_configurations'
include Rails.application.routes.url_helpers

namespace :arduino_server do
  desc 'Arduino Socket Server'

  arduino_server_conf = ArduinoServerConfigurations.new

  task :start => :environment do
    print("Start socket server at port: #{arduino_server_conf.port}\n")
    socket_pools = {}

    server = TCPServer.open(arduino_server_conf.host, arduino_server_conf.port)
    loop do
      Thread.start(server.accept) do |client|
        tap_id = nil

        # startup
        loop do
          tap_id = client.readline.to_i
          client.puts('OK')
          break if client.readline.start_with?('OK')
        end
        # end startup

        socket_pools[tap_id] = client
        tap_opened = false

        loop do
          action, rfid, record_id, water_used = client.readline.split(' ')
          if action.to_i.zero? == tap_opened
            if action.to_i == 1
              uri = URI(on_tap_url(tap_id, host: arduino_server_conf.rails_host))
              res = Net::HTTP.post_form(uri, rfid: rfid)
              if res.code == '200' && res.body.to_i == 1
                client.puts(res.body)
                tap_opened = !tap_opened
              else
                client.puts('0')
              end
            elsif action.to_i == 0
              uri = URI(off_tap_url(tap_id, host: arduino_server_conf.rails_host))
              res = Net::HTTP.post_form(uri, rfid: rfid, record_id: record_id, water_used: water_used)
              if res.code == '200' && res.body.to_i == 1
                client.puts(res.body)
                tap_opened = !tap_opened
              else
                client.puts('0')
              end
            end
          end
        end
      end
    end
  end
end
