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
        unless failed_events.empty?
          @failure_message = "Expected to be able to respond to: #{failed_events.join(', ')}"
        end

        failure_message.nil?
      end
    end
  end
end
