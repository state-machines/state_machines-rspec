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

    transition any => :stoped, :on => :stop

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

