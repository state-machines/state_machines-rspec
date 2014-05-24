require 'state_machine'
require 'state_machine_rspec'
require 'timecop'
require 'rspec/its'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include StateMachineRspec::Matchers
end
