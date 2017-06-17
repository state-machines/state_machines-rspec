# state_machines_rspec
[![Gem Version](https://badge.fury.io/rb/state_machines-rspec.svg)](https://badge.fury.io/rb/state_machines-rspec)

Custom RSpec matchers for [state-machines/state_machine](https://github.com/state-machines/state_machine).

This repo is forked from [modocache/state_machine_rspec](https://github.com/modocache/state_machine_rspec).

## Matchers

### `have_state` & `reject_state`

```ruby
describe Vehicle do
  it { is_expected.to have_states :parked, :idling, :stalled, :first_gear,
                                  :second_gear, :third_gear }
  it { is_expected.to reject_state :flying }

  it { is_expected.to have_states :active, :off, on: :alarm_state }
  it { is_expected.to have_state :active, on: :alarm_state, value: 1 }
  it { is_expected.to reject_states :broken, :ringing, on: :alarm_state }
end
```

### `handle_event` & `reject_event`

```ruby
describe Vehicle do
  it { is_expected.to handle_events :shift_down, :crash, when: :third_gear }
  it { is_expected.to handle_events :enable_alarm, :disable_alarm,
                                    when: :active, on: :alarm_state }
  it { is_expected.to reject_events :park, :ignite, :idle, :shift_up, :repair,
                                    when: :third_gear }
end
```

### `transition_from`

```ruby
describe Vehicle do
  it { is_expected.to transition_from :idling, to_state: :parked,
                                      on_event: :park }
  it { is_expected.to transition_from :idling, :first_gear,
                                      to_state: :parked, on_event: :park }
  it { is_expected.to transition_from :active, to_state: :off,
                                      on_event: :disable_alarm, on: :alarm_state }
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
