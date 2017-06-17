## [0.4.0](https://github.com/state-machines/state_machines-rspec/compare/v0.3.2...v0.4.0)
- Renamed the gem to state_machines-rspec
- Gem ownership is now shared between multiple maintainers 
- Removed deprecated syntax in examples
- Add transition from matcher

## [0.1.3](https://github.com/modocache/state_machine_rspec/compare/v0.1.2...v0.1.3)

- Add `#description` to matchers.
- Update rspec dependency.

## [0.1.2](https://github.com/modocache/state_machine_rspec/compare/v0.1.1...v0.1.2)

- state_machine dependency updated from "~> 1.1.0" to ">= 1.1.0".
  Fixes https://github.com/modocache/state_machine_rspec/issues/5.

## [0.1.1](https://github.com/modocache/state_machine_rspec/compare/v0.1.0...v0.1.1)

- `StateMachineRspec::Matchers::Events` conform to `Matchers::States` API, and now
  take a `:on` parameter when specifying a non-default state_machine attribute. This
  used to be specified with a `:state` parameter.
- Add Travis-CI build status image to README.
- Update README with instructions on including module in during RSpec configuration.

## [0.1.0](https://github.com/modocache/state_machine_rspec/tree/v0.1.0)

- Initial release.
