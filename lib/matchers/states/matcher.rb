require 'active_support/core_ext/array/extract_options'

module StateMachineRspec
  module Matchers
    module States
      class Matcher
        attr_reader :failure_message

        def initialize(states)
          @options = states.extract_options!
          @states = states
        end

        def description
          @states.map{ |event| event.inspect }.join(', ')
        end

        def matches?(subject)
          raise_if_multiple_values

          @subject = subject
          @introspector = StateMachineIntrospector.new(@subject,
                                                       state_machine_scope)

          return false unless matches_states?(@states)
          @failure_message.nil?
        end

        def matches_states?(states)
          raise NotImplementedError,
            "subclasses of #{self.class} must override matches_states?"
        end

        protected

        def state_machine_scope
          @options.fetch(:on, nil)
        end

        def state_value
          @options.fetch(:value, nil)
        end

        private

        def raise_if_multiple_values
          if @states.count > 1 && state_value
            raise ArgumentError, 'cannot make value assertions on ' +
                                 'multiple states at once'
          end
        end
      end
    end
  end
end

