module StateMachineRspec
  module Matchers
    def respond_to_events(value, *values)
      RespondToEventMatcher.new(values.unshift(value))
    end
    alias_method :respond_to_event, :respond_to_events

    class RespondToEventMatcher
      attr_reader :failure_message

      def initialize(events)
        @events = events
      end

      def matches?(subject)
        failed_events = @events.reject { |e| subject.send("can_#{e}?") }
        if failed_events.empty?
          true
        else
          @failure_message = "Expected to be able to respond to: #{failed_events.join(', ')}"
          false
        end
      end
    end
  end
end
