module Schedule
  class Item
    def initialize (limit, component)
      @limit = limit
      @component = component
    end
    
    def component_name
      @component.name
    end
    
    def logged_component_run
      Factory::Log.timer(@component.name) { @component.run }
    end
  end
end
