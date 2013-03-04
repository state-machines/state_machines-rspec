require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    def respond_to_events(value, *values)
      RespondToEventMatcher.new(values.unshift(value))
    end
    alias_method :respond_to_event, :respond_to_events

    class RespondToEventMatcher
      attr_reader :failure_message

      def initialize(events)
        @options = events.extract_options!
        @events = events
      end

      def matches?(subject)
        @subject = subject

        if state_name = @options.fetch(:when, nil)
          when_states = machine.states.reject { |s| s.name != state_name }
          subject.send("#{machine.attribute}=", when_states.first.value)
        end

        failed_events = @events.reject { |e| subject.send("can_#{e}?") }
        unless failed_events.empty?
          @failure_message = "Expected to be able to respond to: " +
                              "#{failed_events.join(', ')} in state: " +
                              "#{subject.send(machine.attribute)}"
        end

        failure_message.nil?
      end

      private

      def machine
        if state_attr = @options.fetch(:state, nil)
          machine = @subject.class.state_machines[state_attr]
        else
          machine = @subject.class.state_machine
        end
      end
    end
  end
end
