require 'spec_helper'

describe StateMachinesRspec::Matchers::RejectStateMatcher do
  describe '#matches?' do
    context 'when :on state machines attribute is specified' do
      before { @matcher = described_class.new([:supportive, on: :environment]) }
      context 'but that state machines doesn\'t exist' do
        before { @class = Class.new }
        it 'raises' do
          expect { @matcher.matches? @class.new }.to raise_error
        end
      end

      context 'and that state machines exists' do
        context 'but it defines states which match one of the specified states' do
          before do
            @class = Class.new do
              state_machine :environment, initial: :supportive
            end
          end

          it 'sets a failure message' do
            @matcher.matches? @class.new
            expect(@matcher.failure_message).to eq('Did not expect environment to allow states: supportive')
          end
          it 'returns false' do
            expect(@matcher.matches?(@class.new)).to be_falsey
          end
        end

        context 'and it does not define any of the states specified' do
          before do
            @class = Class.new do
              state_machine :environment, initial: :conducive
            end
          end

          it 'does not set a failure message' do
            @matcher.matches? @class.new
            expect(@matcher.failure_message).to  be_nil
          end
          it 'returns true' do
            expect(@matcher.matches?(@class.new)).to be_truthy
          end
        end
      end
    end

    context 'when :on state machines is not specified' do
      before { @matcher = described_class.new([:ever_changing]) }
      context 'but the default state machines defines states which match one of the specified states' do
        before do
          @class = Class.new do
            state_machine initial: :ever_changing
          end
        end

          it 'sets a failure message' do
            @matcher.matches? @class.new
            expect(@matcher.failure_message).to eq('Did not expect state to allow states: ever_changing')
          end
          it 'returns false' do
            expect(@matcher.matches?(@class.new)).to be_falsey
          end
      end

      context 'and the default state machines does not define any of the states specified' do
        before { @class = Class.new }
        it 'does not set a failure message' do
          @matcher.matches? @class.new
          expect(@matcher.failure_message).to  be_nil
        end
        it 'returns true' do
          expect(@matcher.matches?(@class.new)).to be_truthy
        end
      end
    end
  end

  describe '#description' do
    context 'with no options' do
      let(:matcher) { described_class.new([:mustard, :tomatoes]) }

      it 'returns a string description' do
        expect(matcher.description).to eq('not have :mustard, :tomatoes')
      end
    end

    context 'when :on state machines is specified' do
      let(:matcher) { described_class.new([:peanut_butter, on: :toast]) }

      it 'mentions the state machines variable' do
        expect(matcher.description).to eq('not have :peanut_butter on :toast')
      end
    end
  end
end
