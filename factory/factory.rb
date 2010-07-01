class Factory
  def Factory.use (db_library)
    require "#{ANSWER_FACTORY_ROOT}/database/#{db_library}/factory"
    self
  end
  
  def Factory.run (n = 1)
    Factory::Log.timer("Factory.run") do
      Signal.trap(:INT) {|x| Log.write("Factory.run was terminated prematurely."); raise Shutdown }
      
      n.times do
        @schedule.each do |item|
          item.run
        end
      end
    end
  end
  
  extend Schedule
  
  instance_eval { undef new }
  
  Shutdown = Class.new(StandardError)
  
  Factory.use(:none)
end
