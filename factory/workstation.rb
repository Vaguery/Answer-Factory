class Workstation
  attr_reader :name
  attr_reader :answers_by_machine
  attr_reader :answers_to_be_saved
  attr_accessor :cycles
  
  def initialize (symbol_name, &config)
    extend Schedule
    
    @name = symbol_name
    @cycles = 1
    
    Factory.components[symbol_name] = self
    
    setup
    
    config.call(self) if block_given?
  end
  
  # overwrite in subclasses
  def setup
  end
  
  def run
    return if @schedule.empty?
    
    load_answers_and_distribute_to_machines!
    
    @cycles.times do
      @schedule.each do |item|
        item.run
      end
    end
    
    save_answers!
  end
  
  def load_answers_and_distribute_to_machines!
    @answers_by_machine = Hash.new {|hash,key| hash[key] = [] }
    @answers_to_be_saved = Answer.new_empty_collection
    
    answers = Answer.load_for_workstation(@name)
    
    Factory::Log.answers(:load, answers)
    
    default_machine_name = @schedule.first.component_name
    
    answers.each do |answer|
      @answers_by_machine[answer.machine_name || default_machine_name] << answer
    end
  end
  
  def save_answers!
    @answers_by_machine.each do |machine_name, answers|
      machine_name = nil unless @components[machine_name]
      
      Answer.relocate(answers, @name, machine_name)
      
      @answers_to_be_saved.concat(answers)
    end
    
    Answer.save(@answers_to_be_saved)
    
    Factory::Log.answers(:save, @answers_to_be_saved)
  end
end
