class Factory
  class Log
    @disable = false
    @stream = false
    @log = []
    @nest = 0
    
    def Log.stream= (true_or_false)
      @stream = true_or_false
    end
    
    def Log.disable= (true_or_false)
      @disable = true_or_false
    end
    
    def Log.write (message)
      return if @disable
      
      indent = "  " * @nest
      
      time = Time.now
      usec = "%03d" % (time.usec / 1000)
      timestamp = time.strftime("[%a %b %d %Y %T.#{usec}] ")
      
      entry = timestamp + indent + message
      
      @stream ? puts(entry) : @log << entry
    end
    
    def Log.timer (event_name)
      return yield if @disable
      
      Log.write("#{event_name}...")
      @nest += 1
      
      start = Time.now
      yield
      elapsed = "%0.3fs" % (Time.now - start)
      
      @nest -= 1
      Log.write("...[#{elapsed}]")
    end
    
    def Log.answers (action, answers, workstation_name = nil, machine_name = nil)
      workstation_name = "#{workstation_name}:" if workstation_name
      where = " to #{workstation_name}#{machine_name}" if machine_name
      
      n = answers.length
      s = "s" unless n == 1
      
      Log.write("{#{action} #{n} answer#{s}#{where}}")
    end
  end
end
