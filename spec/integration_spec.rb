require 'spec_helper'

class Vehicle
  attr_accessor :seatbelt_on, :time_used, :auto_shop_busy

  state_machine :state, :initial => :parked do
    before_transition :parked => any - :parked, :do => :put_on_seatbelt

    after_transition :on => :crash, :do => :tow
    after_transition :on => :repair, :do => :fix
    after_transition any => :parked do |vehicle, transition|
      vehicle.seatbelt_on = false
    end

    after_failure :on => :ignite, :do => :log_start_failure

    around_transition do |vehicle, transition, block|
      start = Time.now
      block.call
      vehicle.time_used += Time.now - start
    end

    event :park do
      transition [:idling, :first_gear] => :parked
    end

    event :ignite do
      transition :stalled => same, :parked => :idling
    end

    event :idle do
      transition :first_gear => :idling
    end

    event :shift_up do
      transition :idling => :first_gear, :first_gear => :second_gear, :second_gear => :third_gear
    end

    event :shift_down do
      transition :third_gear => :second_gear, :second_gear => :first_gear
    end

    event :crash do
      transition all - [:parked, :stalled] => :stalled, :if => lambda {|vehicle| !vehicle.passed_inspection?}
    end

    event :repair do
      # The first transition that matches the state and passes its conditions
      # will be used
      transition :stalled => :parked, :unless => :auto_shop_busy
      transition :stalled => same
    end

    state :parked do
      def speed
        0
      end
    end

    state :idling, :first_gear do
      def speed
        10
      end
    end

    state all - [:parked, :stalled, :idling] do
      def moving?
        true
      end
    end

    state :parked, :stalled, :idling do
      def moving?
        false
      end
    end
  end

  state_machine :alarm_state, :initial => :active, :namespace => 'alarm' do
    event :enable do
      transition all => :active
    end

    event :disable do
      transition all => :off
    end

    state :active, :value => 1
    state :off, :value => 0
  end

  def initialize
    @seatbelt_on = false
    @time_used = 0
    @auto_shop_busy = true
    super() # NOTE: This *must* be called, otherwise states won't get initialized
  end

  def put_on_seatbelt
    @seatbelt_on = true
  end

  def passed_inspection?
    false
  end

  def tow
    # tow the vehicle
  end

  def fix
    # get the vehicle fixed by a mechanic
  end

  def log_start_failure
    # log a failed attempt to start the vehicle
  end
end


describe Vehicle do
  let(:vehicle) { Vehicle.new }
  subject { vehicle }

  its(:passed_inspection?) { should be_false }

  shared_examples 'crashable' do
    describe 'crash' do
      context 'having passed inspection' do
        before { vehicle.stub(:passed_inspection).and_return(true) }
        pending 'keeps running' do
          initial_state = vehicle.state
          vehicle.crash!

          vehicle.state.should eq initial_state
        end
      end

      context 'not having passed inspection' do
        before { vehicle.stub(:passed_inspection).and_return(false) }
        it 'stalls' do
          vehicle.crash!
          vehicle.state.should eq :stalled.to_s
        end
      end
    end
  end

  describe '#initialize' do
    its(:seatbelt_on) { should be_false }
    its(:time_used) { should eq 0 }
    its(:auto_shop_busy) { should be_true }
  end

  describe '#put_on_seatbelt' do
    it 'sets seatbelt_on to true' do
      vehicle.seatbelt_on = false

      vehicle.put_on_seatbelt

      vehicle.seatbelt_on.should be_true
    end
  end

  describe 'state machine' do
    it 'has an initial state of "parked"' do
      vehicle.should be_parked
    end

    it 'has an initial alarm state of "active"' do
      vehicle.alarm_active?.should be_true
    end

    describe 'around transitions' do
      it 'updates the time used' do
        vehicle.should_receive(:time_used=).with(0)
        Timecop.freeze { vehicle.ignite! }
      end
    end

    context 'when parked' do
      before { vehicle.state = :parked.to_s }

      its(:can_park?) { should be_false }
      its(:can_ignite?) { should be_true }
      its(:can_idle?) { should be_false }
      its(:can_shift_up?) { should be_false }
      its(:can_shift_down?) { should be_false }
      its(:can_crash?) { should be_false }
      its(:can_repair?) { should be_false }

      its(:speed) { should be_zero }
      it { should_not be_moving }

      describe 'before transitions' do
        it 'puts on a seatbelt' do
          vehicle.should_receive :put_on_seatbelt
          vehicle.ignite!
        end
      end

      describe 'ignite' do
        it 'should transition to idling' do
          vehicle.ignite!
          vehicle.should be_idling
        end
      end
    end

    context 'when transitioning to parked' do
      before { vehicle.state = :idling.to_s }
      it 'removes seatbelts' do
        vehicle.should_receive(:seatbelt_on=).with(false)
        vehicle.park!
      end
    end

    context 'when idling' do
      before { vehicle.state = :idling.to_s }

      its(:can_park?) { should be_true }
      its(:can_ignite?) { should be_false }
      its(:can_idle?) { should be_false }
      its(:can_shift_up?) { should be_true }
      its(:can_shift_down?) { should be_false }
      its(:can_crash?) { should be_true }
      its(:can_repair?) { should be_false }

      its(:speed) { should eq 10 }
      it { should_not be_moving }

      describe 'park' do
        it 'should transition to a parked state' do
          vehicle.park!
          vehicle.should be_parked
        end
      end

      describe 'shift up' do
        it 'should shift into first gear' do
          vehicle.shift_up!
          vehicle.should be_first_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when stalled' do
      before { vehicle.state = :stalled.to_s }

      its(:can_park?) { should be_false }
      its(:can_ignite?) { should be_true }
      its(:can_idle?) { should be_false }
      its(:can_shift_up?) { should be_false }
      its(:can_shift_down?) { should be_false }
      its(:can_crash?) { should be_false }
      its(:can_repair?) { should be_true }

      it { should_not be_moving }

      it 'does not respond to speed' do
        expect { vehicle.speed }.to raise_error NoMethodError
      end

      describe 'ignite' do
        it 'remains stalled' do
          vehicle.ignite!
          vehicle.should be_stalled
        end
      end

      describe 'repair' do
        context 'the auto shop is busy' do
          before { vehicle.stub(:auto_shop_busy).and_return(true) }
          it 'remains stalled' do
            vehicle.repair!
            vehicle.should be_stalled
          end
        end

        context 'the auto shop is not busy' do
          before { vehicle.stub(:auto_shop_busy).and_return(false) }
          it 'is parked' do
            vehicle.repair!
            vehicle.should be_parked
          end
        end
      end
    end

    context 'when in first gear' do
      before { vehicle.state = :first_gear.to_s }

      its(:can_park?) { should be_true }
      its(:can_ignite?) { should be_false }
      its(:can_idle?) { should be_true }
      its(:can_shift_up?) { should be_true }
      its(:can_shift_down?) { should be_false }
      its(:can_crash?) { should be_true }
      its(:can_repair?) { should be_false }

      its(:speed) { should eq 10 }
      it { should be_moving }

      describe 'park' do
        it 'parks' do
          vehicle.park!
          vehicle.should be_parked
        end
      end

      describe 'idle' do
        it 'idles' do
          vehicle.idle!
          vehicle.should be_idling
        end
      end

      describe 'shift up' do
        it 'shift into second gear' do
          vehicle.shift_up!
          vehicle.should be_second_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when in second gear' do
      before { vehicle.state = :second_gear.to_s }

      its(:can_park?) { should be_false }
      its(:can_ignite?) { should be_false }
      its(:can_idle?) { should be_false }
      its(:can_shift_up?) { should be_true }
      its(:can_shift_down?) { should be_true }
      its(:can_crash?) { should be_true }
      its(:can_repair?) { should be_false }

      it { should be_moving }

      it 'does not respond to speed' do
        expect { vehicle.speed }.to raise_error NoMethodError
      end

      describe 'shift up' do
        it 'shifts into third gear' do
          vehicle.shift_up!
          vehicle.should be_third_gear
        end
      end

      describe 'shift down' do
        it 'shifts back into first gear' do
          vehicle.shift_down!
          vehicle.should be_first_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'when in third gear' do
      before { vehicle.state = :third_gear.to_s }

      its(:can_park?) { should be_false }
      its(:can_ignite?) { should be_false }
      its(:can_idle?) { should be_false }
      its(:can_shift_up?) { should be_false }
      its(:can_shift_down?) { should be_true }
      its(:can_crash?) { should be_true }
      its(:can_repair?) { should be_false }

      it { should be_moving }

      it 'does not respond to speed' do
        expect { vehicle.speed }.to raise_error NoMethodError
      end

      describe 'shift down' do
        it 'shifts back into second gear' do
          vehicle.shift_down!
          vehicle.should be_second_gear
        end
      end

      it_behaves_like 'crashable'
    end

    context 'on ignition' do
      context 'when it fails' do
        before { vehicle.stub(:ignite).and_return(false) }
        pending 'logs the failure' do
          vehicle.should_receive(:log_start_failure)
          vehicle.ignite
        end
      end
    end

    context 'on a crash' do
      before { vehicle.state = :third_gear.to_s }
      it 'gets towed' do
        vehicle.should_receive(:tow)
        vehicle.crash!
      end
    end

    context 'upon being repaired' do
      before { vehicle.state = :stalled.to_s }
      it 'gets fixed' do
        vehicle.should_receive(:fix)
        vehicle.repair!
      end
    end
  end

  describe 'alarm state machine' do
    it 'has an initial state of activated' do
      vehicle.alarm_active?.should be_true
    end

    context 'when active' do
      its(:alarm_state) { should eq 1 }

      its(:can_enable_alarm?) { should be_true }
      its(:can_disable_alarm?) { should be_true }

      describe 'enable' do
        it 'becomes active' do
          vehicle.enable_alarm!
          vehicle.alarm_active?.should be_true
        end
      end

      describe 'disable' do
        it 'turns the alarm off' do
          vehicle.disable_alarm!
          vehicle.alarm_off?.should be_true
        end
      end
    end

    context 'when off' do
      before { vehicle.alarm_state = 0 }

      its(:alarm_state) { should be_zero }

      its(:can_enable_alarm?) { should be_true }
      its(:can_disable_alarm?) { should be_true }

      describe 'enable' do
        it 'becomes active' do
          vehicle.enable_alarm!
          vehicle.alarm_active?.should be_true
        end
      end

      describe 'disable' do
        it 'turns the alarm off' do
          vehicle.disable_alarm!
          vehicle.alarm_off?.should be_true
        end
      end
    end
  end
end
