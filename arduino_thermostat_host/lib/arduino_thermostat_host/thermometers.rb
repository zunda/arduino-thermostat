require 'serialport'

module ArduinoThermostatHost
  class Thermometers
    Defaults = {
      path: '/dev/ttyUSB0',
      speed: 9600,
      timeout: 15,
    }

    def self.measure(options = {})
      conf = Defaults.merge(options)
      sp = SerialPort.new(conf[:path], conf[:speed])
      sp.read_timeout = conf[:timeout]
      puts sp.read
    end
  end
end
