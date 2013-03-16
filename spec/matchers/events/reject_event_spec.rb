require 'spec_helper'

describe StateMachineRspec::Matchers::RejectEventMatcher do
  describe '#matches?' do
    context 'when :when state is specified' do
      context 'but that state doesn\'t exist' do
        before do
          matcher_class = Class.new do
            state_machine :state, initial: :sleazy
          end
          @matcher_subject = matcher_class.new
          @matcher = described_class.new([when: :sneezy])
        end

        it 'raises' do
          expect { @matcher.matches? @matcher_subject }.
            to raise_error StateMachineIntrospectorError
        end
      end

      context 'and that state exists' do
        before do
          matcher_class = Class.new do
            state_machine :state, initial: :sleazy do
              state :sneezy
            end
          end
          @matcher_subject = matcher_class.new
          @matcher = described_class.new([when: :sneezy])
        end

        it 'sets the state' do
          @matcher.matches? @matcher_subject
          @matcher_subject.state.should eq 'sneezy'
        end
      end
    end

    context 'when an expectation is made on an event that is undefined' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :snarky do
            event(:primmadonnalize) { transition any => same }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new([:primmadonnalize, :martinilunchitize])
      end

      it 'does not raise' do
        expect { @matcher.matches?(@matcher_subject) }.to_not raise_error
      end
      it 'sets a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.
          should eq 'state_machine: state does not ' +
                    'define events: martinilunchitize'
      end
      it 'returns false' do
        @matcher.matches?(@matcher_subject).should be_false
      end
    end

    context 'when subject cannot perform any of the specified events' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :snarky do
            state :haughty
            event(:primmadonnalize) { transition :haughty => same }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new([:primmadonnalize])
      end

      it 'does not set a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.should be_nil
      end
      it 'returns true' do
        @matcher.matches?(@matcher_subject).should be_true
      end
    end

    context 'when subject can perform any one of the specified events' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :snarky do
            state :haughty
            event(:primmadonnalize) { transition :haughty => same }
            event(:defer_to_management) { transition any => same }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new([:primmadonnalize, :defer_to_management])
      end

      it 'sets a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.
          should eq 'Did not expect to be able to handle events: defer_to_management ' +
                    'in state: snarky'
      end
      it 'returns false' do
        @matcher.matches?(@matcher_subject).should be_false
      end
    end
  end
end
