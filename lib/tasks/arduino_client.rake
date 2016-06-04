require 'socket'
require 'tasks/arduino_client_emulator_configurations'

namespace :arduino_client do
  desc 'Arduino Socket Client'

  arduino_client_emu_conf = ArduinoClientEmulatorConfigurations.new

  task :start => :environment do
    water_used = Random.rand(1...100)

    puts("Connect socket server #{arduino_client_emu_conf.host} at port: #{arduino_client_emu_conf.port}")
    socket = TCPSocket.open(arduino_client_emu_conf.host, arduino_client_emu_conf.port)

    # startup
    socket.puts(arduino_client_emu_conf.tap_id.to_s)
    unless socket.readline.start_with?('OK')
      puts('Failed to startup connection...')
      exit
    end
    socket.puts('OK')
    # end startup

    puts("Try to turn tap:#{arduino_client_emu_conf.tap_id} on...")

    socket.puts("1 #{arduino_client_emu_conf.rfid}")
    result, record_id = socket.readline.split(' ')
    if result.to_i == 1
      puts("Turn tap on success! Get record_id: #{record_id}")
    elsif result.to_i == 0
      puts('Turn tap on failed!')
    end

    puts("Try to turn tap:#{arduino_client_emu_conf.tap_id} off...")

    socket.puts("0 #{arduino_client_emu_conf.rfid} #{record_id} #{water_used}")
    res = socket.readline
    if res.to_i == 1
      puts('Turn tap off success!')
    elsif res.to_i == 0
      puts('Turn tap off failed!')
    end
  end
end
