require 'state_machines'
require 'state_machines-rspec'
require 'timecop'
require 'rspec/its'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include StateMachinesRspec::Matchers
end
