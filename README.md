# state_machine_rspec

Custom matchers for [pluginaweek/state_machine](https://github.com/pluginaweek/state_machine).

## Installation

Add this line to your application's Gemfile:

    gem 'state_machine_rspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install state_machine_rspec

## Matchers

### `have_state`

```ruby
describe Vehicle do
  it { should have_states :alarm_state, :active, :off }
  it { should have_state :alarm_state, :active, value: 1 }
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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
