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
        @states = states
      end

      def matches?(subject)
        if machine = subject.class.state_machines[@state_attr]
          defined_states = machine.states.map(&:name)
          failing_states = @states.reject { |s| defined_states.include? s }
          unless failing_states.empty?
            @failure_message = "Expected #{@state_attr} to allow state: " +
                               "#{failing_states.join(', ')}"
          end
        else
          @failure_message = "#{subject.class} does not have a " +
                             "state machine defined on #{@state_attr}"
        end

        @failure_message.nil?
      end
    end
  end
end
