require 'wemote'

# Monkey patch for additional MAC address for Belkin
module Wemote
  class Switch
		BelkinMacs = %w(b4:75:0e 14:91:82)
		class << self
			def Switch.discover
				ip = UDPSocket.open {|s| s.connect(GOOGLE_IP, 1); s.addr.last}
				`nmap -sP #{ip.split('.')[0..-2].join('.')}.* > /dev/null && arp -na`.
				split("\n").
				select{|l| BelkinMacs.any?{|m| l.include?("at #{m}")}}.map do |device|
					self.new(/\((\d+\.\d+\.\d+\.\d+)\)/.match(device)[1])
				end.reject{|device| device.instance_variable_get(:@port).nil? }
			end
    end
  end
end

module ArduinoThermostatHost
  class Pump
		Name = 'Pump for water heater'

		def initialize(name = Name)
			@switch = Wemote::Switch.find(name)
			raise "#{name} was not found on the network" unless @switch
		end

		def state
			return @switch.on? ? :on : :off
		end

		def on!
			@switch.on!
		end

		def off!
			@switch.off!
		end
  end
end
