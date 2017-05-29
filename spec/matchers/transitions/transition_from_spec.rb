require 'spec_helper'

describe StateMachinesRspec::Matchers::HandleTransitionFromMatcher do
  describe '#matches?' do
    context 'when :from states and :on_event is specified but the :to_state doesn\'t exist' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :mathy do
            event(:mathematize) { transition any => same }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new(:mathy, on_event: :mathematize)
      end

      it 'raises' do
        expect { @matcher.matches? @matcher_subject }
          .to raise_error StateMachinesIntrospectorError, 'Option :to_state cannot be nil'
      end
    end

    context 'when :from states and :to_state is specified but the :on_event doesn\'t exist' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :mathy do
            state :polynomial

            event(:mathematize) { transition any => same }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new(:mathy, to_state: :polynomial)
      end

      it 'raises' do
        expect { @matcher.matches? @matcher_subject }
          .to raise_error StateMachinesIntrospectorError, 'Option :on_event cannot be nil'
      end
    end

    context 'when :from states, :to_state and :on_event is specified' do
      context 'and :to_state doesn\'t defined' do
        before do
          matcher_class = Class.new do
            state_machine :state, initial: :mathy do
              state :artsy

              event(:mathematize) { transition any => same }
            end
          end
          @matcher_subject = matcher_class.new
          @matcher = described_class.new(:mathy, to_state: :polynomial, on_event: :mathematize)
        end

        it 'raise' do
          expect { @matcher.matches? @matcher_subject }
            .to raise_error StateMachinesIntrospectorError, "#{@matcher_subject.class} does not define state: polynomial"
        end
      end

      context 'and :on_event doesn\'t defined' do
        before do
          matcher_class = Class.new do
            state_machine :state, initial: :mathy do
              state :artsy

              event(:mathematize) { transition any => same }
            end
          end
          @matcher_subject = matcher_class.new
          @matcher = described_class.new(:mathy, to_state: :arsty, on_event: :algebraify)
        end

        it 'raise' do
          expect { @matcher.matches? @matcher_subject }
            .to raise_error StateMachinesIntrospectorError, "#{@matcher_subject.class} does not define event :algebraify"
        end
      end

      context 'and from state doesn\'t defined' do
        before do
          matcher_class = Class.new do
            state_machine :state, initial: :mathy do
              state :artsy

              event(:mathematize) { transition any => same }
            end
          end
          @matcher_subject = matcher_class.new
          @matcher = described_class.new(:polynomial, to_state: :arsty, on_event: :mathematize)
        end

        it 'raise' do
          expect { @matcher.matches? @matcher_subject }
            .to raise_error StateMachinesIntrospectorError, "#{@matcher_subject.class} does not define state: polynomial"
        end
      end
    end

    context 'when subject can perform transition' do
      before do
        matcher_class = Class.new do
          state_machine :mathiness, initial: :mathy do
            state :polynomial

            event(:algebraify) { transition polynomial: :mathy }
          end
        end
        @matcher_subject = matcher_class.new
        @matcher = described_class.new(:polynomial, to_state: :mathy, on_event: :algebraify, on: :mathiness)
      end

      it 'does not set a failure message' do
        @matcher.matches? @matcher_subject
        expect(@matcher.failure_message).to be_nil
      end
      it 'returns true' do
        expect(@matcher.matches?(@matcher_subject)).to be_truthy
      end
    end

    context 'when subject cannot perform events' do
      before do
        matcher_class = Class.new do
          state_machine :state, initial: :mathy do
            state :polynomial

            event(:algebraify) { transition polynomial: same }
            event(:trigonomalize) { transition trigonomalize: same }
          end
        end
        @matcher_subject = matcher_class.new
      end

      context 'because it cannot perform the event' do
        before do
          @matcher = described_class.new(:mathy, to_state: :polynomial, on_event: :algebraify)
        end

        it 'sets a failure message' do
          @matcher.matches? @matcher_subject
          expect(@matcher.failure_message).to eq('Expected to be able to transition state from: ' \
                                                 'mathy to: polynomial, on_event: algebraify')
        end
        it 'returns false' do
          expect(@matcher.matches?(@matcher_subject)).to be_falsey
        end
      end
    end

    describe '#description' do
      context 'with one from state' do
        let(:matcher) { described_class.new(:mathy, to_state: :polynomial, on_event: :trigonomalize) }

        it 'returns a string description' do
          expect(matcher.description).to eq('transition state to :polynomial from :mathy on event :trigonomalize')
        end
      end

      context 'when multiple from states' do
        let(:matcher) { described_class.new(:mathy, :arsty, to_state: :polynomial, on_event: :trigonomalize) }

        it 'mentions the requisite state' do
          expect(matcher.description).to eq('transition state to :polynomial from :mathy, :arsty on event :trigonomalize')
        end
      end

      context 'when :on is specified' do
        let(:matcher) { described_class.new(:mathy, to_state: :polynomial, on_event: :trigonomalize, on: :mathiness) }

        it 'mentions the state machines variable' do
          expect(matcher.description).to eq('transition state to :polynomial from :mathy on event :trigonomalize on :mathiness')
        end
      end
    end
  end
end
