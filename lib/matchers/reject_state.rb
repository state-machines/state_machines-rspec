require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    def reject_states(state, *states)
      RejectStateMatcher.new(states.unshift(state))
    end
    alias_method :reject_state, :reject_states

    class RejectStateMatcher
      attr_reader :failure_message

      def initialize(states)
        @options = states.extract_options!
        @states = states
      end

      def matches?(subject)
        @subject = subject
        @introspector = StateMachineIntrospector.new(@subject,
                                                     @options.fetch(:on, nil))

        no_defined_states?
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
