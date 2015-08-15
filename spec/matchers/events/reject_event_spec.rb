require 'spec_helper'

describe StateMachinesRspec::Matchers::RejectEventMatcher do
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
            to raise_error StateMachinesIntrospectorError
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
          expect(@matcher_subject.state).to eq('sneezy')
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
        expect { @matcher.matches?(@matcher_subject) }.not_to raise_error
      end
      it 'sets a failure message' do
        @matcher.matches? @matcher_subject
        expect(@matcher.failure_message).to eq('state_machine: state does not ' +
                                               'define events: martinilunchitize')
      end
      it 'returns false' do
        expect(@matcher.matches?(@matcher_subject)).to be_falsey
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
        expect(@matcher.failure_message).to  be_nil
      end
      it 'returns true' do
        expect(@matcher.matches?(@matcher_subject)).to be_truthy
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
        expect(@matcher.failure_message).to eq('Did not expect to be able to handle events: defer_to_management ' +
                                               'in state: snarky')
      end
      it 'returns false' do
        expect(@matcher.matches?(@matcher_subject)).to be_falsey
      end
    end
  end

  describe '#description' do
    context 'with no options' do
      let(:matcher) { described_class.new([:makeadealify, :hustlinate]) }

      it 'returns a string description' do
        expect(matcher.description).to  eq('reject :makeadealify, :hustlinate')
      end
    end

    context 'when :when state is specified' do
      let(:matcher) { described_class.new([:begargle, when: :sleep_encrusted]) }

      it 'mentions the requisite state' do
        expect(matcher.description).to  eq('reject :begargle when :sleep_encrusted')
      end
    end

    context 'when :on is specified' do
      let(:matcher) { described_class.new([:harrangue, on: :suspicious_crowd]) }

      it 'mentions the state machines variable' do
        expect(matcher.description).to  eq('reject :harrangue on :suspicious_crowd')
      end
    end
  end
end
