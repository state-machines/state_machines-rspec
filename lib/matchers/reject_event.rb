require 'matchers/events/matcher'

module StateMachineRspec
  module Matchers
    def reject_events(value, *values)
      RejectEventMatcher.new(values.unshift(value))
    end
    alias_method :reject_event, :reject_events

    class RejectEventMatcher < StateMachineRspec::Matchers::Events::Matcher
      def matches_events?(events)
        !valid_events?
      end

      private

      def valid_events?
        valid_events = @introspector.valid_events(@events)
        unless valid_events.empty?
          @failure_message = "Did not expect to be able to handle events: " +
                              "#{valid_events.join(', ')} in state: " +
                              "#{@introspector.current_state_value}"
        end

        !valid_events.empty?
      end
    end
  end
end
