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
