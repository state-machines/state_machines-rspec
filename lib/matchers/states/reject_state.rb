require 'matchers/states/matcher'

module StateMachineRspec
  module Matchers
    def reject_states(state, *states)
      RejectStateMatcher.new(states.unshift(state))
    end
    alias_method :reject_state, :reject_states

    class RejectStateMatcher < StateMachineRspec::Matchers::States::Matcher
      def matches_states?(states)
        no_defined_states?
      end

      def description
        message = super
        message << " on #{state_machine_scope.inspect}" if state_machine_scope
        "not have #{message}"
      end

      private

      def no_defined_states?
        defined_states = @introspector.defined_states(@states)
        unless defined_states.empty?
          @failure_message = "Did not expect #{@introspector.state_machine_attribute} " +
                             "to allow states: #{defined_states.join(', ')}"
        end

        defined_states.empty?
      end
    end
  end
end
