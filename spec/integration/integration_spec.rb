require 'spec_helper'
require 'integration/models/vehicle'

describe Vehicle do
  let(:vehicle) { Vehicle.new }
  subject { vehicle }

  its(:passed_inspection?) { is_expected.to be_falsey }

  shared_examples 'crashable' do
    describe 'crash' do
      context 'having passed inspection' do
        before { allow(vehicle).to receive_messages(:passed_inspection => true) }
        pending 'keeps running' do
          initial_state = vehicle.state
          vehicle.crash!

          expect(vehicle.state).to  eq initial_state
        end
      end

      context 'not having passed inspection' do
        before { allow(vehicle).to receive_messages(:passed_inspection => false) }
        it 'stalls' do
          vehicle.crash!
          expect(vehicle.state).to  eq :stalled.to_s
        end
      end
    end
  end

  shared_examples 'speedless' do
    it 'does not respond to speed' do
      expect { vehicle.speed }.to raise_error StateMachines::InvalidContext
    end
  end

  describe '#initialize' do
    its(:seatbelt_on) { is_expected.to be_falsey }
    its(:time_used) { is_expected.to eq 0 }
    its(:auto_shop_busy) { is_expected.to be_truthy }
  end

  describe '#put_on_seatbelt' do
    it 'sets seatbelt_on to true' do
      vehicle.seatbelt_on = false
      vehicle.put_on_seatbelt

      expect(vehicle.seatbelt_on).to  be_truthy
    end
  end

  describe 'state machines' do
    it { is_expected.to have_states :parked, :idling, :stalled, :first_gear,
                            :second_gear, :third_gear }
    it { is_expected.to reject_state :flying }

    it { is_expected.to handle_event :ignite, when: :parked }
    it { is_expected.to reject_events :park, :idle, :shift_up,
                              :shift_down, :crash, :repair,
                              when: :parked }

    it { is_expected.to handle_events :park, :shift_up, :crash, when: :idling }
    it { is_expected.to reject_events :ignite, :idle, :shift_down, :repair,
                              when: :idling }

    it { is_expected.to handle_events :ignite, :repair, when: :stalled }
    it { is_expected.to reject_events :park, :idle, :shift_up, :shift_down, :crash,
                              when: :stalled }

    it { is_expected.to handle_events :park, :idle, :shift_up, :crash,
                              when: :first_gear }
    it { is_expected.to reject_events :ignite, :shift_down, :repair,
                              when: :first_gear }

    it { is_expected.to handle_events :shift_up, :shift_down, :crash,
                              when: :second_gear }
    it { is_expected.to reject_events :park, :ignite, :idle, :repair,
                              when: :second_gear }

    it { is_expected.to handle_events :shift_down, :crash, when: :third_gear }
    it { is_expected.to reject_events :park, :ignite, :idle, :shift_up, :repair,
                              when: :third_gear }

    it 'has an initial state of "parked"' do
      expect(vehicle).to  be_parked
    end

    it 'has an initial alarm state of "active"' do
      expect(vehicle.alarm_active?).to be_truthy
    end

    describe 'around transitions' do
      it 'updates the time used' do
        expect(vehicle).to receive(:time_used=).with(0)
        Timecop.freeze { vehicle.ignite! }
      end
    end

    context 'when parked' do
      before { vehicle.state = :parked.to_s }

      its(:speed) { is_expected.to be_zero }
      it { is_expected.not_to be_moving }

      describe 'before transitions' do
        it 'puts on a seatbelt' do
          expect(vehicle).to receive :put_on_seatbelt
          vehicle.ignite!
        end
      end

      describe 'ignite' do
        it 'should transition to idling' do
          vehicle.ignite!
          expect(vehicle).to  be_idling
        end
      end
    end

    context 'when transitioning to parked' do
      before { vehicle.state = :idling.to_s }
      it 'removes seatbelts' do
        expect(vehicle).to receive(:seatbelt_on=).with(false)
        vehicle.park!
      end
    end

    context 'when idling' do
      before { vehicle.state = :idling.to_s }

      its(:speed) { is_expected.to eq 10 }
      it { is_expected.not_to be_moving }

      describe 'park' do
        it 'should transition to a parked state' do
          vehicle.park!
          expect(vehicle).to  be_parked
        end
      end

      describe 'shift up' do
        it 'should shift into first gear' do
          vehicle.shift_up!
          expect(vehicle).to  be_first_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when stalled' do
      before { vehicle.state = :stalled.to_s }

      it { is_expected.not_to be_moving }
      it_behaves_like 'speedless'

      describe 'ignite' do
        it 'remains stalled' do
          vehicle.ignite!
          expect(vehicle).to  be_stalled
        end
      end

      describe 'repair' do
        context 'the auto shop is busy' do
          before { allow(vehicle).to receive_messages(:auto_shop_busy => true) }
          it 'remains stalled' do
            vehicle.repair!
            expect(vehicle).to  be_stalled
          end
        end

        context 'the auto shop is not busy' do
          before { allow(vehicle).to receive_messages(:auto_shop_busy => false) }
          it 'is parked' do
            vehicle.repair!
            expect(vehicle).to  be_parked
          end
        end
      end
    end

    context 'when in first gear' do
      before { vehicle.state = :first_gear.to_s }

      its(:speed) { is_expected.to eq 10 }
      it { is_expected.to be_moving }

      describe 'park' do
        it 'parks' do
          vehicle.park!
          expect(vehicle).to  be_parked
        end
      end

      describe 'idle' do
        it 'idles' do
          vehicle.idle!
          expect(vehicle).to  be_idling
        end
      end

      describe 'shift up' do
        it 'shift into second gear' do
          vehicle.shift_up!
          expect(vehicle).to  be_second_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when in second gear' do
      before { vehicle.state = :second_gear.to_s }

      it { is_expected.to be_moving }
      it_behaves_like 'speedless'

      describe 'shift up' do
        it 'shifts into third gear' do
          vehicle.shift_up!
          expect(vehicle).to  be_third_gear
        end
      end

      describe 'shift down' do
        it 'shifts back into first gear' do
          vehicle.shift_down!
          expect(vehicle).to  be_first_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when in third gear' do
      before { vehicle.state = :third_gear.to_s }

      it { is_expected.to be_moving }
      it_behaves_like 'speedless'

      describe 'shift down' do
        it 'shifts back into second gear' do
          vehicle.shift_down!
          expect(vehicle).to  be_second_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'on ignition' do
      context 'when it fails' do
        before { allow(vehicle).to receive_messages(:ignite => false) }
        pending 'logs the failure' do
          expect(vehicle).to receive(:log_start_failure)
          vehicle.ignite
        end
      end
    end

    context 'on a crash' do
      before { vehicle.state = :third_gear.to_s }
      it 'gets towed' do
        expect(vehicle).to receive(:tow)
        vehicle.crash!
      end
    end

    context 'upon being repaired' do
      before { vehicle.state = :stalled.to_s }
      it 'gets fixed' do
        expect(vehicle).to receive(:fix)
        vehicle.repair!
      end
    end
  end

  describe 'alarm state machines' do
    it { is_expected.to have_state :active, on: :alarm_state, value: 1 }
    it { is_expected.to have_state :off, on: :alarm_state, value: 0 }
    it { is_expected.to reject_states :broken, :ringing, on: :alarm_state }

    it { is_expected.to handle_events :enable_alarm, :disable_alarm,
                              when: :active, on: :alarm_state }
    it { is_expected.to handle_events :enable_alarm, :disable_alarm,
                              when: :off, on: :alarm_state }

    it 'has an initial state of activated' do
      expect(vehicle.alarm_active?).to be_truthy
    end

    context 'when active' do
      describe 'enable' do
        it 'becomes active' do
          vehicle.enable_alarm!
          expect(vehicle.alarm_active?).to be_truthy
        end
      end

      describe 'disable' do
        it 'turns the alarm off' do
          vehicle.disable_alarm!
          expect(vehicle.alarm_off?).to be_truthy
        end
      end
    end

    context 'when off' do
      before { vehicle.alarm_state = 0 }
      describe 'enable' do
        it 'becomes active' do
          vehicle.enable_alarm!
          expect(vehicle.alarm_active?).to be_truthy
        end
      end

      describe 'disable' do
        it 'turns the alarm off' do
          vehicle.disable_alarm!
          expect(vehicle.alarm_off?).to be_truthy
        end
      end
    end
  end
end
