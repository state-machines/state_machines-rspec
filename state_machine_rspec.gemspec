# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'state_machine_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'state_machine_rspec'
  spec.version       = StateMachineRspec::VERSION
  spec.authors       = ['modocache']
  spec.email         = ['modocache@gmail.com']
  spec.description   = %q{ RSpec matchers for state_machine. }
  spec.summary       = %q{ RSpec matchers for state_machine. }
  spec.homepage      = 'http://github.com/modocache/state_machine_rspec'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'terminal-notifier-guard'

  spec.add_dependency 'rspec', '~> 2.9'
  spec.add_dependency 'state_machine', '~> 1.1.0'
  spec.add_dependency 'activesupport', '~> 3.2.12'
end
