# state_machines_rspec


Custom RSpec matchers for [state-machines/state_machine](https://github.com/state-machines/state_machine).

This repo is forked from [modocache/state_machine_rspec](https://github.com/modocache/state_machine_rspec).

## Matchers

### `have_state` & `reject_state`

```ruby
describe Vehicle do
  it { should have_states :parked, :idling, :stalled, :first_gear,
                          :second_gear, :third_gear }
  it { should reject_state :flying }

  it { should have_states :active, :off, on: :alarm_state }
  it { should have_state :active, on: :alarm_state, value: 1 }
  it { should reject_states :broken, :ringing, on: :alarm_state }
end
```

### `handle_event` & `reject_event`

```ruby
describe Vehicle do
  it { should handle_events :shift_down, :crash, when: :third_gear }
  it { should handle_events :enable_alarm, :disable_alarm,
                            when: :active, on: :alarm_state }
  it { should reject_events :park, :ignite, :idle, :shift_up, :repair,
                            when: :third_gear }
end
```


## Installation

Add these lines to your application's Gemfile:

```ruby
group :test do
  gem 'state_machines_rspec'
end
```

(Note that the orginal `state_machine_rspec` used `state_machine` singular and I'm using `state_machines` plural to fit in with `state-machines/state_machines`.)

And include the matchers in `spec/spec_helper.rb` or `spec/rails_helper.rb`

```ruby
RSpec.configure do |config|
  config.include StateMachinesRspec::Matchers
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
