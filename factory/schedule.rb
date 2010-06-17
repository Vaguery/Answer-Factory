module Schedule
  def Schedule.extended (object)
    object.instance_variable_set(:@schedule, [])
    object.instance_variable_set(:@components, {})
    
    def object.components
      @components
    end
  end
  
  def schedule (*items)
    @schedule = items.collect do |item|
      case item
        when Symbol
          CountedRun.new(1, @components[item])
        
        when Array
          case item[1]
            when /([0-9]+)x/
              CountedRun.new($1.to_i, @components[item[0]])
            
            when /([0-9]+(?:\.[0-9]+)?)s/
              TimedRun.new($1.to_f, @components[item[0]])
            
            when /([0-9]+(?:\.[0-9]+)?)m/
              TimedRun.new($1.to_f * 60, @components[item[0]])
            
            when /([0-9]+(?:\.[0-9]+)?)h/
              TimedRun.new($1.to_f * 60 * 60, @components[item[0]])
          end
        
        when CountedRun, TimedRun
          item
      end
    end.compact
    
    self
  end
end
