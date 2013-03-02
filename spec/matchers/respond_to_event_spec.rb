require 'spec_helper'

describe StateMachineRspec::Matchers::RespondToEventMatcher do
  describe '#matches?' do
    context 'when subject can perform events' do
      before do
        @matcher = described_class.new([:mathematize])
        @matcher_subject = double('mathematician mock', can_mathematize?: true)
      end
      it 'does not set a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.should be_nil
      end
      it 'returns true' do
        @matcher.matches?(@matcher_subject).should be_true
      end
    end

    context 'when subject cannot perform events' do
      before do
        @matcher = described_class.new([:mathematize, :algebraify, :trigonomalize])
        @matcher_subject = double('mathematician mock', can_mathematize?: true,
                                                        can_algebraify?: false,
                                                        can_trigonomalize?: false)
      end
      it 'sets a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.
          should eq 'Expected to be able to respond to: algebraify, trigonomalize'
      end
      it 'returns true' do
        @matcher.matches?(@matcher_subject).should be_false
      end
    end
  end
end
