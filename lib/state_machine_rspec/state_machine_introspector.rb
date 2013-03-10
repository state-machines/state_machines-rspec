class StateMachineIntrospector
  def initialize(subject)
    @klass = subject.class
  end

  def state_machine(attr)
    if attr
      @klass.state_machines[attr]
    else
      @klass.state_machine
    end
  end

end
