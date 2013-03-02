require 'spec_helper'

describe StateMachineRspec::Matchers::HaveStateMatcher do
  describe '#matches?' do
    before { @matcher = described_class.new(:radical_state, [:rad, :not_so_rad]) }
    context 'when class does not have a matching state attribute' do
      before do
        @class = Class.new do
          state_machine :bodacious_state, initial: :super_bodacious
        end
      end
      it 'sets a failure message indicating the state attribute is not defined' do
        @matcher.matches? @class.new
        @matcher.failure_message.should =~ /.+? does not have a state machine defined on radical_state/
      end
      it 'returns false' do
        @matcher.matches?(@class.new).should be_false
      end
    end

    context 'when class has a matching state attribute' do
      context 'and has all states specified' do
        before do
          @class = Class.new do
            state_machine :radical_state do
              state :rad
              state :not_so_rad
            end
          end
        end
        it 'does not set a failure message' do
          @matcher.matches? @class.new
          @matcher.failure_message.should be_nil
        end
        it 'returns true' do
          @matcher.matches?(@class.new).should be_true
        end
      end

      context 'but is missing some of the specified states' do
        before do
          @class = Class.new do
            state_machine :radical_state do
              state :not_so_rad
            end
          end
        end
        it 'sets a failure message indicating a state is missing' do
          @matcher.matches? @class.new
          @matcher.failure_message.should eq 'Expected radical_state to allow state: rad'
        end
        it 'returns false' do
          @matcher.matches?(@class.new).should be_false
        end
      end
    end
  end
end
