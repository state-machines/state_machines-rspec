require 'spec_helper'

describe StateMachinesRspec::Matchers::HaveStateMatcher do
  describe '#matches?' do
    before { @matcher = described_class.new([:rad, :not_so_rad, { on: :radical_state }]) }

    context 'when values are asserted on multiple states' do
      before do
        @matcher = described_class.new([:rad, :not_so_rad, { value: 'rad' }])
      end
      it 'raises an ArgumentError' do
        expect { @matcher.matches? nil }.to raise_error ArgumentError,
          'cannot make value assertions on multiple states at once'
      end
    end

    context 'when class does not have a matching state attribute' do
      before do
        @class = Class.new do
          state_machine :bodacious_state, initial: :super_bodacious
        end
      end

      it 'raises' do
        expect { @matcher.matches? @class.new }.
          to raise_error StateMachinesIntrospectorError,
            /.+? does not have a state machine defined on radical_state/
      end
    end

    context 'when class has a matching state attribute' do
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
          expect(@matcher.failure_message).to eq 'Expected radical_state to allow states: rad'
        end
        it 'returns false' do
          expect(@matcher.matches?(@class.new)).to be_falsey
        end
      end

      context 'and has all states specified' do
        before do
          @class = Class.new do
            state_machine :radical_state do
              state :rad, value: 'totes rad'
              state :not_so_rad, value: 'meh'
            end
          end
        end

        context 'state values not specified' do
          it 'does not set a failure message' do
            @matcher.matches? @class.new
            expect(@matcher.failure_message).to be_nil
          end
          it 'returns true' do
            expect(@matcher.matches?(@class.new)).to be_truthy
          end
        end

        context 'state value matches specified value' do
          before do
            @matcher = described_class.new([:rad, { on: :radical_state, value: 'uber-rad' }])
            @class = Class.new do
              state_machine :radical_state do
                state :rad, value: 'uber-rad'
              end
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

        context 'state value does not match specified value' do
          before do
            @matcher = described_class.new([:rad, { on: :radical_state, value: 'uber-rad' }])
            @class = Class.new do
              state_machine :radical_state do
                state :rad, value: 'kinda rad'
              end
            end
          end

          it 'does not set a failure message' do
            @matcher.matches? @class.new
            expect(@matcher.failure_message).to  eq 'Expected rad to have value uber-rad'
          end
          it 'returns true' do
            expect(@matcher.matches?(@class.new)).to be_falsey
          end
        end
      end
    end
  end

  describe '#description' do
    context 'with no options' do
      let(:matcher) { described_class.new([:fancy_shirt, :cracked_toenail]) }

      it 'returns a string description' do
        expect(matcher.description).to  eq('have :fancy_shirt, :cracked_toenail')
      end
    end

    context 'when :value is specified' do
      let(:matcher) { described_class.new([:mustache, value: :really_shady]) }

      it 'mentions the requisite state' do
        expect(matcher.description).to  eq('have :mustache == :really_shady')
      end
    end

    context 'when :on state machines is specified' do
      let(:matcher) { described_class.new([:lunch, on: :tuesday]) }

      it 'mentions the state machines variable' do
        expect(matcher.description).to  eq('have :lunch on :tuesday')
      end
    end
  end
end
