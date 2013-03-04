require 'spec_helper'

describe StateMachineRspec::Matchers::RespondToEventMatcher do
  describe '#matches?' do
    before do
      @matcher_class = Class.new do
        state_machine :state, initial: :mathy
      end
    end
    context 'when subject can perform events' do
      before do
        @matcher = described_class.new([:mathematize])
        @matcher_subject = @matcher_class.new
        @matcher_subject.stub(:can_mathematize?).and_return(true)
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
        @matcher_subject = @matcher_class.new
        @matcher_subject.stub(:can_mathematize?).and_return(true)
        @matcher_subject.stub(:can_algebraify?).and_return(false)
        @matcher_subject.stub(:can_trigonomalize?).and_return(false)
      end
      it 'sets a failure message' do
        @matcher.matches? @matcher_subject
        @matcher.failure_message.
          should eq 'Expected to be able to respond to: algebraify, trigonomalize ' +
                    'in state: mathy'
      end
      it 'returns true' do
        @matcher.matches?(@matcher_subject).should be_false
      end
    end
  end
end
