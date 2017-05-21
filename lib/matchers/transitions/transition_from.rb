require 'active_support/core_ext/array/extract_options'

module StateMachinesRspec
  module Matchers
    def transition_from(*values)
      HandleTransitionFromMatcher.new(*values)
    end

    alias transitions_from transition_from

    class HandleTransitionFromMatcher
      attr_reader :failure_message, :options, :from_states, :from_state,
                  :state_machine_scope

      def initialize(*values)
        @options = values.extract_options!
        @state_machine_scope = @options.fetch(:on, nil)
        @from_states = values
      end

      def matches?(subject)
        @subject = subject
        @introspector = StateMachinesIntrospector.new(@subject, state_machine_scope)
        from_states.each do |from_state|
          @from_state = from_state
          enter_from_state
          return false unless valid_transition?
          break if @failure_message
        end
        @failure_message.nil?
      end

      def description
        message = "transition state to :#{options[:to_state]} from "
        message << from_states.map{ |state| ":#{state}" }.join(', ')
        message << " on event :#{options[:on_event]}"
        message << " on #{state_machine_scope.inspect}" if state_machine_scope
        message
      end

      def valid_transition?
        valid_transition = @introspector.valid_transition?(event, to_state)
        unless valid_transition
          @failure_message = 'Expected to be able to transition state from: ' \
            "#{from_state} to: #{to_state}, on_event: #{event}"
        end

        valid_transition
      end

      def event
        @event ||=
          unless event = options[:on_event]
            raise StateMachinesIntrospectorError, 'Option :on_event cannot be nil'
          end
        unless @introspector.event_defined?(event)
          raise StateMachinesIntrospectorError, "#{@subject.class} does not define event :#{event}"
        end
        event
      end

      def to_state
        @to_state ||=
          unless state_name = options[:to_state]
            raise StateMachinesIntrospectorError, 'Option :to_state cannot be nil'
          end
        unless  state = @introspector.state(state_name)
          raise StateMachinesIntrospectorError, "#{@subject.class} does not define state: #{state_name}"
        end
        state.value
      end

      private

      def enter_from_state
        unless state = @introspector.state(from_state)
          raise StateMachinesIntrospectorError, "#{@subject.class} does not define state: #{from_state}"
        end
        @subject.send("#{@introspector.state_machine_attribute}=", state.value)
      end
    end
  end
end
