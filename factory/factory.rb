# encoding: UTF-8
class Factory
  def Factory.setup (&config)
    @workstations = {}
    @schedule = []
    
    Factory.instance_eval(&config)
  end
  
  def Factory.database (options)
    require File.expand_path("../built-in/adapters/#{options['adapter']}", File.dirname(__FILE__))
    extend const_get("#{options['adapter'].capitalize}Adapter")
    Factory.set_database(options)
  end
  
  def Factory.workstation (workstation_name, class_name = :Workstation, &config)
    workstation = const_get(class_name).new(workstation_name, &config)
    
    @workstations[workstation_name.to_sym] = workstation
    @schedule << workstation_name.to_sym
    workstation
  end
  
  def Factory.schedule (*workstation_names)
    @schedule = workstation_names.collect {|name| name.to_sym }
  end
  
  def Factory.run
    # self.check
    
    loop do
      @schedule.each do |workstation_name|
        @workstations[workstation_name].run
      end
    end
  end
  
  def Factory.score (answers, scorer_class)
    scorer_class.new(answers).score
  end
end
