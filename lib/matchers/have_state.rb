require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    def have_states(state_attr, state, *states)
      HaveStateMatcher.new(state_attr, states.unshift(state))
    end
    alias_method :have_state, :have_states

    class HaveStateMatcher
      attr_reader :failure_message

      def initialize(state_attr, states)
        @state_attr = state_attr
        @options = states.extract_options!
        @states = states
      end

      def matches?(subject)
        raise_if_multiple_values

        if machine = subject.class.state_machines[@state_attr]
          defined_states = machine.states.map(&:name)
          failing_states = @states.reject { |s| defined_states.include? s }

          if failing_states.empty?
            if state_value && machine.states[@states.first].value != state_value
              @failure_message = "Expected #{@states.first} to have value #{state_value}"
            end
          else
            @failure_message = "Expected #{@state_attr} to allow state: " +
                               "#{failing_states.join(', ')}"
          end
        else
          @failure_message = "#{subject.class} does not have a " +
                             "state machine defined on #{@state_attr}"
        end

        @failure_message.nil?
      end

      private

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
