class Workstation
  attr_reader :name,
              :machines
  
  def initialize (name)
    @name = name
    @machines = {}
    @schedule = []
    
    Factory::Workstations[name] = self
    
    setup
    
    yield self if block_given?
  end
  
  def setup
  end
  
  def schedule (*machine_names)
    @schedule = machine_names
  end
  
  def run
    @answers_to_be_saved = []
    @answers_by_machine = Factory.load_answers(self)
    
  # run machines
    @schedule.each do |machine_name|
      Factory::Log.run(machine_name, @machines[machine_name])
    end
    
  # queue answers that remain in local machines
    @answers_by_machine.each do |machine_name, answers|
      queue(answers, @name, machine_name)
    end
    
  # save answers to database
    Factory.save_answers(@answers_to_be_saved)
  end
  
  def dump (machine_name)
    @answers_by_machine[machine_name].slice!(0..-1)
  end
  
  def transfer (answers, machine_name)
    @answers_by_machine[machine_name || default_machine_name].concat(answers)
  end
  
  def queue (answers, workstation_name, machine_name)
    answers.each do |answer|
      answer.workstation = workstation_name
      answer.machine = machine_name
    end
    
    @answers_to_be_saved.concat(answers)
  end
  
  def default_machine_name
    @schedule.first || :none
  end
end
