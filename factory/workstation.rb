# encoding: UTF-8
class Workstation
  def initialize (workstation_name, &config)
    @name = workstation_name.to_sym
    @machines = {}
    @schedule = []
    
    setup
    
    self.instance_eval(&config) if config
  end
  
  def machine (machine_name, class_name = :Machine, &config)
    machine = Object.const_get(class_name).new("#{@name}:#{machine_name}", &config)
    
    @machines[machine_name.to_sym] = machine
    @schedule << machine_name.to_sym
    machine
  end
  
  def setup
  end
  
  def schedule (*machine_names)
    @schedule = machine_names.collect {|name| name.to_sym }
  end
  
  def run
    @schedule.each do |machine_name|
      @machines[machine_name.to_sym].run
    end
  end
end
