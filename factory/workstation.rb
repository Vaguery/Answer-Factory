# encoding: UTF-8
class Workstation
  # call-seq:
  #   Workstation.new (name: Symbol) {|w| config } -> workstation
  # 
  # Creates a new workstation, and stores it in Factory::Workstations with
  # the key +name+.
  # 
  # If a +config+ block is provided, it runs at the end of initialization,
  # passing the newly created workstation as its parameter.
  # 
  #   w = Workstation.new(:w) do |workstation|
  #     Machine.new(:m, w) do |m|
  #       ...
  #     end
  #     
  #     w.schedule :m
  #   end
  #   
  #   w.inspect       #=> #<Workstation:0x10012bdc0 @name=:w,
  #                         @machines={:m1=>#<Machine:0x100490128>}
  #                         @schedule=[:m]>
  # 
  def initialize (name)
    @name = name.to_sym
    @machines = {}
    @schedule = []
    
    Factory::Workstations[@name] = self
    
    setup
    
    yield self if block_given?
  end
  
  # call-seq:
  #   workstation.schedule (machine_name: Symbol, * ) -> [symbol, * ]
  # 
  # Stores the given machine names in the @+schedule+ array.
  # 
  #   Workstation.new (:w) do |w|
  #     Machine.new (:m1, w)
  #     Machine.new (:m2, w)
  #     
  #     w.schedule :m1, :m1, :m2, :m1, :m2
  #   end
  # 
  def schedule (*machine_names)
    @schedule = machine_names
  end
  
  # 
  # Loads this workstation's answers and distributes them into the
  # @answers_by_machine hash, then calls #run on each machine named in
  # the @schedule array.
  # 
  # After running the entire schedule, reassigns all the answers remaining in
  # local machines and then saves the @answers_to_be_saved queue.
  # 
  def run # :nodoc:
    return if @schedule.empty?
    
    @answers_to_be_saved = []
    @answers_by_machine = Factory.load_answers(@name, @schedule.first)
    
    @schedule.each do |machine_name|
      unless machine = @machines[machine_name]
        raise Factory::MachineMissing, "no machine named #{machine_name.inspect}"
      end
      
      Factory::Log.run(machine_name, machine)
    end
    
    @answers_by_machine.each do |machine_name, answers|
      @answers_to_be_saved.concat answers.each {|answer| answer.assign(@name, machine_name) }
    end
    
    Factory.save_answers(@answers_to_be_saved)
  end
  
  # 
  # Defined separately in each class that inherits from Workstation.
  # Empty by default.
  # 
  def setup # :nodoc:
  end
  
  # 
  # Called from Machine#run. Empties the array of answers associated with the
  # named machine and returns its contents.
  # 
  def dump (machine_name) # :nodoc:
    @answers_by_machine[machine_name].slice!(0..-1)
  end
  
  # 
  # Called from Machine#run. Moves the answers to the correct machine's
  # answers array if reassigning to a local machine; otherwise assigns the
  # given workstation_name and machine_name to each answer, then adds the
  # answers to the @answers_to_be_saved queue.
  # 
  def reassign (answers, workstation_name, machine_name = nil) # :nodoc:
    if workstation_name == @name
      @answers_by_machine[machine_name || @schedule.first].concat(answers)
    else
      @answers_to_be_saved.concat answers.each {|answer| answer.assign(workstation_name, machine_name) }
    end
  end
end
