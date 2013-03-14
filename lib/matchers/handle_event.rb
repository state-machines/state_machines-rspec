require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    def handle_events(value, *values)
      HandleEventMatcher.new(values.unshift(value))
    end
    alias_method :handle_event, :handle_events

    class HandleEventMatcher
      attr_reader :failure_message

      def initialize(events)
        @options = events.extract_options!
        @events = events
      end

      def matches?(subject)
        @subject = subject
        @introspector = StateMachineIntrospector.new(@subject,
                                                     @options.fetch(:state, nil))
        enter_when_state
        return false if undefined_events?
        return false if invalid_events?
        @failure_message.nil?
      end

      private

      def enter_when_state
        if state_name = @options.fetch(:when, nil)
          unless when_state = @introspector.state(state_name)
            raise StateMachineIntrospectorError,
              "#{@subject.class} does not define state: #{state_name}"
          end

          @subject.send("#{@introspector.state_machine_attribute}=",
                        when_state.value)
        end
      end

      def undefined_events?
        undefined_events = @introspector.undefined_events(@events)
        unless undefined_events.empty?
          @failure_message = "state_machine: #{@introspector.state_machine_attribute} " +
                             "does not define events: #{undefined_events.join(', ')}"
        end

        !undefined_events.empty?
      end

      def invalid_events?
        invalid_events = @introspector.invalid_events(@events)
        unless invalid_events.empty?
          @failure_message = "Expected to be able to handle events: " +
                              "#{invalid_events.join(', ')} in state: " +
                              "#{@introspector.current_state_value}"
        end

        !invalid_events.empty?
      end
    end
  end
end
