# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arduino_thermostat_host/version'

Gem::Specification.new do |spec|
  spec.name          = "arduino_thermostat_host"
  spec.version       = ArduinoThermostatHost::VERSION
  spec.authors       = ["zunda"]
  spec.email         = ["zundan@gmail.com"]

  spec.summary       = %q{Control solar water heater}
  spec.description   = %q{With temperature sensors on an Arduino, this program controls water pump on a WeMo switch to heat water under Sunshine.}
  spec.homepage      = "https://github.com/zunda/arduino-thermostat/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "no where"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", ">= 12.3.3"

  spec.add_dependency "serialport", "~> 1.3"
  spec.add_dependency "wemote", "~> 0.2.2"
end
