require 'matchers/events/matcher'

module StateMachineRspec
  module Matchers
    def handle_events(value, *values)
      HandleEventMatcher.new(values.unshift(value))
    end
    alias_method :handle_event, :handle_events

    class HandleEventMatcher < StateMachineRspec::Matchers::Events::Matcher
      def matches_events?(events)
        !invalid_events?
      end

      private

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
