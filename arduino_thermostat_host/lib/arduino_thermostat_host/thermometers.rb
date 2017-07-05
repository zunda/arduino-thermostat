require 'serialport'

module ArduinoThermostatHost
  class Thermometers
    attr_reader :time # timestamp
    attr_reader :t1 # temperature for A0
    attr_reader :t2 # temperature for A1

    def Thermometers.measure
      sp = SerialPort.new(Conf[:path], Conf[:speed])
      sp.flush_input
      while true
        t1, t2 = sp.gets.chomp.scan(/([\d\.]+)\s+([\d\.]+)/)[0]
        ts = Time.now
        break if t2
      end
      sp.close
      return Thermometers.new(ts, Float(t1), Float(t2))
    end

    Conf = {
      path: '/dev/ttyUSB0',
      speed: 9600,
    }

    def initialize(time, t1, t2)
      @time = time
      @t1 = t1
      @t2 = t2
    end
  end
end
