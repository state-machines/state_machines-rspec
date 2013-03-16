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

        def matches?(subject)
          raise_if_multiple_values

          @subject = subject
          @introspector = StateMachineIntrospector.new(@subject,
                                                       @options.fetch(:on, nil))

          return false unless matches_states?(@states)
          @failure_message.nil?
        end

        def matches_states?(states)
          raise NotImplementedError,
            "subclasses of #{self.class} must override matches_states?"
        end

        private

        def raise_if_multiple_values
          if @states.count > 1 && @options.fetch(:value, nil)
            raise ArgumentError, 'cannot make value assertions on ' +
                                 'multiple states at once'
          end
        end
      end
    end
  end
end

