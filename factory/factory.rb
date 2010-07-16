class << Factory = Class.new
  undef new
  
  def database (options)
    require File.expand_path("../database/#{options['adapter']}_adapter", File.dirname(__FILE__))
    set_database(options)
  end
  
  def config (text)
    save_config(text)
  end
  
  def schedule (items)
    clear_schedule
    
    items.each do |item|
      case item
        when Hash
          key, value = item.first
          
          case value
            when /([0-9]+)x/              then schedule_item($1.to_i, "x", key)
            when /([0-9]+(?:\.[0-9]+)?)s/ then schedule_item($1.to_f, "s", key)
            when /([0-9]+(?:\.[0-9]+)?)m/ then schedule_item($1.to_f * 60, "s", key)
            when /([0-9]+(?:\.[0-9]+)?)h/ then schedule_item($1.to_f * 60 * 60, "s", key)
          end
        
        when String, Symbol               then schedule_item(1, "x", item)
      end
    end
  end
  
  def run
    loop do
      Object.instance_eval(read_config)
      next_item {|name| Factory::Log.run(name, Factory::Workstations[name]) }
    end
  end
  
  Factory::Workstations = {}
  
  Factory::MachineNotCreated = Class.new(StandardError)
end
