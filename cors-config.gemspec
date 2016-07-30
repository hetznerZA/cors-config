# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cors/config/version'

Gem::Specification.new do |spec|
  spec.name          = "cors-config"
  spec.version       = Cors::Config::VERSION
  spec.authors       = ["daneb"]
  spec.email         = ["dane.balia@hetzner.co.za"]

  spec.summary       = %q{CORS Configuration Gem.}
  spec.homepage      = "http://github.com/hetznerZA/cors-config"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack-cors", "~> 0.4.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rack", "~> 2.0"
  spec.add_development_dependency "rack-test"
end
