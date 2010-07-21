class Machine
  # call-seq:
  #   Machine.new (name: Symbol, w: Workstation) {|m| config } -> machine
  # 
  # Creates a new machine referenced by +name+ inside workstation +w+.
  # 
  # If a +config+ block is provided, it runs at the end of initialization,
  # passing the newly created machine as its parameter.
  # 
  #   m = Machine.new(:m, workstation) do |machine|
  #     machine.opt1 = 100
  #     machine.opt2 = 200
  #     
  #     machine.path[:a] = :w, :n
  #     machine.path[:b] = :w
  #     
  #     def machine.process (answers)
  #       ...
  #     end
  #   end
  #   
  #   m.inspect       #=> #<Machine:0x10012bdc0 @name=:m,
  #                         @opt1=100, @opt2=200,
  #                         @path={:a=>[:w, :n], :b=>:w},
  #                         @workstation=...>
  # 
  def initialize (name, workstation)
    @name = name.to_sym
    @workstation = workstation
    @path = {}
    
    unless @workstation.is_a? Workstation
      raise ArgumentError, "machine requires an instance of Workstation"
    end
    
    @workstation.instance_variable_get(:@machines)[@name] = self
    
    yield self if block_given?
  end
  
  # call-seq:
  #   machine.path -> {:path_name => [:workstation_name, :machine_name], * }
  # 
  # Returns a hash containing this machine's paths.
  # 
  # Example:
  # 
  #   machine.path[:a] = :w, :m
  #   machine.path[:b] = :w
  #   
  #   machine.path    #=> {:a=>[:w, :m], :b=>:w}
  # 
  def path
    @path
  end
  
  # call-seq:
  #   machine.{option_name}= (value) -> value
  # 
  # Creates an instance variable called @+option_name+ and sets it to +value+.
  # 
  # +option_name+ can be any legal instance variable name.
  # 
  #   machine.foo = 1
  #   machine.instance_variable_get(:@foo)  #=> 1
  # 
  def method_missing (method_name, *args)
    symbol_id = method_name.to_i
    
    if (symbol_id % 8) == 4
      return instance_variable_set(:"@#{(symbol_id - 3).to_sym}", args[0])
    end
    
    raise NoMethodError, "undefined method `#{method_name}' for #{self}"
  end
  
  # 
  # Calls #process using this machine's answers from the
  # @answers_by_machine array stored in its parent workstation.
  # 
  # After processing, reassigns the resulting answers to the
  # workstation/machine combinations specified in #process.
  # 
  def run # :nodoc:
    input_answers = @workstation.dump(@name)
    output_hash = process(input_answers)
    
    output_hash.each do |path_name, output_answers|
      @workstation.reassign(output_answers, *@path[path_name])
    end
  end
  
  # 
  # Defined separately in each class that inherits from Machine.
  # 
  # Alternatively, you may define .process as a singleton method for an
  # individual machine, e.g.:
  # 
  #   Machine.new(:m, w) do |m|
  #     def m.process (answers)
  #       ...
  #     end
  #   end
  # 
  def process (answers) # :nodoc:
    raise NoMethodError, "define .process for machine #{@name.inspect} before running factory"
  end
end
