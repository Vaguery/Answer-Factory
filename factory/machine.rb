class Machine
  OPTIONS = {}
  PATHS = []
  SKIP_WHEN_EMPTY = true
  
  class << Machine
    def options (options_hash)
      options_hash.keys.each {|option_name| attr_accessor option_name }
      const_set(:OPTIONS, options_hash)
    end
    
    alias option options
    
    def paths (*path_names)
      const_set(:PATHS, path_names)
    end
    
    alias path paths
  end
  
  attr_reader :name
  attr_reader :path
  
  def initialize (symbol_name, workstation, &config)
    @name = symbol_name
    @path = {}
    
    insert_into workstation
    set_defaults
    config.call(self) if block_given?
  end
  
  def insert_into (workstation)
    unless @workstation = (workstation.is_a? Symbol) ? Factory.components[workstation] : workstation
      raise ArgumentError, "cannot create machine for nonexistent workstation :#{workstation}"
    end
    
    @workstation.components[@name] = self
  end
  
  def set_defaults
    self.class::OPTIONS.each do |option_name, default_value|
      instance_variable_set(:"@#{option_name}", default_value)
    end
    
    self.class::PATHS.each do |path_name, default_value|
      @path[path_name] = default_value || self
    end
  end
  
  def run
    answers_array = @workstation.answers_by_machine[@name]
    return if answers_array.empty? && self.class::SKIP_WHEN_EMPTY
    
    Factory::Log.answers(:with, answers_array)
    Factory::Log.timer("#process") { process(answers_array.slice!(0..-1)) }
    Factory::Log.answers(:keep, answers_array)
  end
  
  # overwrite in subclasses
  def process (answers)
    send_answers(answers, self)
  end
  
  def send_answer (answer, destination)
    send_answers([answer], destination) if answer
  end
  
  def send_answers (answers, destination)
    case destination
      when Symbol
        send_answers_to_workstation(answers, destination)
      
      when Array
        if destination[0] == @workstation.name
          send_answers_to_local_machine(answers, destination[1])
        else
          send_answers_to_workstation(answers, *destination)
        end
      
      when Machine
        send_answers_to_local_machine(answers, destination.name)
    end
  end
  
  def send_answers_to_local_machine (answers, machine_name)
    Factory::Log.answers(:send, answers, nil, machine_name) unless machine_name == @name
    
    @workstation.answers_by_machine[machine_name].concat(answers)
  end
  
  def send_answers_to_workstation (answers, workstation_name, machine_name = nil)
    Answer.relocate(answers, workstation_name, machine_name)
    
    Factory::Log.answers(:send, answers, workstation_name, machine_name)
    
    @workstation.answers_to_be_saved.concat(answers)
  end
end
