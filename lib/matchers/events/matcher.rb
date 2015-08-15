require 'active_support/core_ext/array/extract_options'

module StateMachinesRspec
  module Matchers
    module Events
      class Matcher
        attr_reader :failure_message

        def initialize(events)
          @options = events.extract_options!
          @events = events
        end

        def matches?(subject)
          @subject = subject
          @introspector = StateMachinesIntrospector.new(@subject,
                                                       @options.fetch(:on, nil))
          enter_when_state
          return false if undefined_events?
          return false unless matches_events?(@events)
          @failure_message.nil?
        end

        def matches_events?(events)
          raise NotImplementedError,
            "subclasses of #{self.class} must override matches_events?"
        end

        def description
          message = @events.map{ |event| event.inspect }.join(', ')
          message << " when #{state_name.inspect}" if state_name
          message
        end

        protected

        def state_machine_scope
          @options.fetch(:on, nil)
        end

        private

        def enter_when_state
          if state_name
            unless when_state = @introspector.state(state_name)
              raise StateMachinesIntrospectorError,
                "#{@subject.class} does not define state: #{state_name}"
            end

            @subject.send("#{@introspector.state_machine_attribute}=",
                          when_state.value)
          end
        end

        def state_name
          @options.fetch(:when, nil)
        end

        def undefined_events?
          undefined_events = @introspector.undefined_events(@events)
          unless undefined_events.empty?
            @failure_message = "state_machine: #{@introspector.state_machine_attribute} " +
                               "does not define events: #{undefined_events.join(', ')}"
          end

          !undefined_events.empty?
        end
      end
    end
  end
end
