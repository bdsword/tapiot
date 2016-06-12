require 'socket'
require 'redis'
require 'net/http'
require 'tasks/arduino_server_configurations'
include Rails.application.routes.url_helpers

namespace :arduino_server do
  desc 'Arduino Socket Server'

  arduino_server_conf = ArduinoServerConfigurations.new

  task :start => :environment do
    socket_pools = {}
    turn_off_tokens = {}
    tap_opened = {}

    Thread.new do
      redis = Redis.new
      begin
        redis.subscribe(:website_active_queue) do |on|
          on.subscribe do |channel, subscriptions|
            puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
          end

          on.message do |channel, message|
            Thread.new do
              puts "##{channel}: #{message}"
              active_arg = eval(message)
              case active_arg[:action]
                when 0
                  turn_off_tokens[active_arg[:tap_id]] = active_arg[:turn_off_token]
                  client_socket = socket_pools[active_arg[:tap_id]]
                  break if client_socket.nil?
                  client_socket.puts('0')
                when 1
                  if socket_pools[active_arg[:tap_id]].present?
                    socket_pools[active_arg[:tap_id]].puts("1 #{active_arg[:record_id]}")
                    tap_opened[active_arg[:tap_id]] = !tap_opened[active_arg[:tap_id]]
                  end
                else
                  puts("Unable to handle this action #{active_arg[:action]}")
              end
              redis.unsubscribe if message == "exit"
            end
          end

          on.unsubscribe do |channel, subscriptions|
            puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
          end
        end
      rescue Redis::BaseConnectionError => error
        puts "#{error}, retrying in 1s"
        sleep 1
        retry
      end
    end


    server = TCPServer.open(arduino_server_conf.host, arduino_server_conf.port)
    print("Start socket server at port: #{arduino_server_conf.port}\n")
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
        tap_opened[tap_id] = false
        puts("Client tap #{tap_id} attached!\n")

        loop do
          action, rfid, record_id, water_used = client.readline.split(' ')
          if action.to_i == 2
            water_used = rfid.to_i
            uri = URI(web_off_update_taps_url(host: arduino_server_conf.rails_host))
            res = Net::HTTP.post_form(uri, turn_off_token: turn_off_tokens[tap_id], water_used: water_used)
            if res.code.to_i != 200
              puts("web off update taps failed: #{res.body}")
            end
            turn_off_tokens.except!(tap_id)
            tap_opened[tap_id] = !tap_opened[tap_id]
            next
          end

          if action.to_i.zero? == tap_opened[tap_id]
            if action.to_i == 1
              uri = URI(on_tap_url(tap_id, host: arduino_server_conf.rails_host))
              res = Net::HTTP.post_form(uri, rfid: rfid)
              if res.code == '200' && res.body.to_i == 1
                client.puts(res.body)
                tap_opened[tap_id] = !tap_opened[tap_id]
              else
                client.puts('0')
              end
            elsif action.to_i == 0
              uri = URI(off_tap_url(tap_id, host: arduino_server_conf.rails_host))
              res = Net::HTTP.post_form(uri, rfid: rfid, record_id: record_id, water_used: water_used)
              if res.code == '200' && res.body.to_i == 1
                client.puts(res.body)
                tap_opened[tap_id] = !tap_opened[tap_id]
              else
                client.puts('0')
              end
            end
          else
            puts("Tap #{tap_id} state mismatch!")
          end
        end
      end
    end
  end
end
