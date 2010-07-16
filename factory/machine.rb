class Machine
  OPTIONS = {}
  PATHS = []
  
  class << Machine
    def options (options_hash)
      options_hash.each {|option_name, v| attr_accessor option_name }
      const_set(:OPTIONS, options_hash)
    end
    
    def paths (*path_names)
      const_set(:PATHS, path_names)
    end
  end
  
  attr_accessor :name,
                :path
  
  def initialize (name, workstation)
    @name = name
    @workstation = workstation
    @path = {}
    
  # insert into workstation
    @workstation.machines[@name] = self
    
  # set option defaults
    self.class::OPTIONS.each do |option_name, default_value|
      instance_variable_set(:"@#{option_name}", default_value)
    end
    
  # set all paths to self
    self.class::PATHS.each do |path_name|
      @path[path_name] = self
    end
    
  # set user configuration
    yield self if block_given?
  end
  
  def run
  # empty out this machine's answers from workstation
    input_answers = @workstation.dump(@name)
    
  # process input answers and get outputs
    output_hash = process(input_answers)
    
  # send output answers down the appropriate paths
    output_hash.each do |path_name, output_answers|
      workstation_name, machine_name = @path[path_name]
      
      if workstation_name == @workstation.name
        @workstation.transfer(output_answers, machine_name)
      else
        @workstation.queue(output_answers, workstation_name, machine_name)
      end
    end
  end
end
