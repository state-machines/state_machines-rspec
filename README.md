# state_machine_rspec

[![Build Status](https://travis-ci.org/modocache/state_machine_rspec.png?branch=master)](https://travis-ci.org/modocache/state_machine_rspec)

Custom matchers for [pluginaweek/state_machine](https://github.com/pluginaweek/state_machine).


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
  it { should reject_events :park, :ignite, :idle, :shift_up, :repair,
                            when: :third_gear }
end
```


## Installation

Add these lines to your application's Gemfile:

```ruby
group :test do
  gem 'state_machine_rspec'
end
```

And include the matchers in `spec/spec_helper.rb`:

```ruby
RSpec.configure do |config|
  config.include StateMachineRspec::Matchers
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
