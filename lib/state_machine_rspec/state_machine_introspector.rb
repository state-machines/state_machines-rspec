class StateMachineIntrospector
  def initialize(subject, state_machine_name=nil)
    @subject = subject
    @state_machine_name = state_machine_name
  end

  def state_machine_attribute
    state_machine.attribute
  end

  def current_state_value
    @subject.send(state_machine_attribute)
  end

  def state(name)
    state = state_machine.states.find { |s| s.name == name }
    if state.nil?
      raise StateMachineIntrospectorError,
        "#{@subject.class} does not define state: #{name}"
    else
      state
    end
  end

  def undefined_events(events)
    events.reject { |e| event_defined? e }
  end

  def invalid_events(events)
    events.reject { |e| valid_event? e }
  end

  private

  def state_machine
    if @state_machine_name
      @subject.class.state_machines[@state_machine_name]
    else
      @subject.class.state_machine
    end
  end

  def event_defined?(event)
    @subject.respond_to? "can_#{event}?"
  end

  def valid_event?(event)
    @subject.send("can_#{event}?")
  end

end

class StateMachineIntrospectorError < StandardError
end
