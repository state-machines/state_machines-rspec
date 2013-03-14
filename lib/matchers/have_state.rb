require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    def have_states(state, *states)
      HaveStateMatcher.new(states.unshift(state))
    end
    alias_method :have_state, :have_states

    class HaveStateMatcher
      attr_reader :failure_message

      def initialize(states)
        @options = states.extract_options!
        @states = states
      end

      def matches?(subject)
        raise_if_multiple_values

        @subject = subject
        @introspector = StateMachineIntrospector.new(@subject,
                                                     @options.fetch(:on, nil))

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
        if state_value && @introspector.state(@states.first).value != state_value
          @failure_message = "Expected #{@states.first} to have value #{state_value}"
          true
        end

        false
      end

      def state_value
        @options.fetch(:value, nil)
      end

      def raise_if_multiple_values
        if @states.count > 1 && state_value
          raise ArgumentError, 'cannot make value assertions on ' +
                               'multiple states at once'
        end
      end
    end
  end
end
