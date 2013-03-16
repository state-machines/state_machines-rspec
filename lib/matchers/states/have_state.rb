require 'matchers/states/matcher'

module StateMachineRspec
  module Matchers
    def have_states(state, *states)
      HaveStateMatcher.new(states.unshift(state))
    end
    alias_method :have_state, :have_states

    class HaveStateMatcher < StateMachineRspec::Matchers::States::Matcher
      def matches_states?(states)
        return false if undefined_states?
        return false if incorrect_value?
        @failure_message.nil?
      end

      private

      def undefined_states?
        undefined_states = @introspector.undefined_states(@states)
        unless undefined_states.empty?
          @failure_message = "Expected #{@introspector.state_machine_attribute} " +
                             "to allow states: #{undefined_states.join(', ')}"
        end

        !undefined_states.empty?
      end

      def incorrect_value?
        state_value = @options.fetch(:value, nil)
        if state_value && @introspector.state(@states.first).value != state_value
          @failure_message = "Expected #{@states.first} to have value #{state_value}"
          true
        end

        false
      end
    end
  end
end
