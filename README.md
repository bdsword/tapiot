# TAPIoT Services
TAPIoT is a project that can bring wisdom to your taps.

[Tapiot](https://github.com/bdsword/tapiot) is a sub-project under TAPIoT, which is the website and server part of TAPIoT. 

## Requirements
1. redis >= 3.0
2. ruby >= 2.2
3. mysql >= 5.5
4. nginx >= 1.10
5. rails >= 4.2

##  Installation & Running

1. Clone this repository and install required gems.
    ```shell
    $ git clone https://github.com/bdsword/tapiot.git
    $ cd tapiot
    $ bundle
    ```

2. Setup database configurations.
    ```shell
    $ cp .env.example .env
    # edit .env and setup your database account and password
    ```

3. Setup **ArduinoServer** configurations.
    ```shell
    $ cp arduino_server_configurations.sample.rb arduino_server_configurations.rb
    # edit arduino_server_configurations.rb and setup your server configurations
    ```

4. Setup **ArduinoClientEmulator** or removed it if you don't need.
    ```shell
    # Option1. If you choose to use **ArduinoClientEmulator**
    $ cp arduino_client_emulator_configurations.sample.rb arduino_client_emulator_configurations.rb
    # edit arduino_client_emulator_configurations.rb and setup your server configurations

    # Option2. If you don't want to use **ArduinoClientEmulator**
    $ rm arduino_client*
    ```
5. Setup database and tables.
    ```shell
    $ rake db:create
    $ rake db:migrate
    ```

6. Run all the services.
    ```shell
    $ rails s # Start rails server, using WEBRick(for development only)
    $ bin/cable # Start ActionCable server
    $ rake arduino_server:start # Start ArduinoServer
    ```

# TAPIoT Devices Side

Please check [tapiot-arduino](https://github.com/bdsword/tapiot-arduino) repository.
