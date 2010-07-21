class Factory
  class << Log = Object.new # :nodoc:
    Log.instance_eval do
      @disable = false
      @stream = false
      @log = []
      @nest = 0
    end
    
    def disable= (true_or_false)
      @disable = true_or_false
    end
    
    def stream= (true_or_false)
      @stream = true_or_false
    end
    
    def write (message)
      return if @disable
      
      indent = "  " * @nest
      
      time = Time.now
      usec = "%03d" % (time.usec / 1000)
      timestamp = time.strftime("[%a %b %d %Y %T.#{usec}] ")
      
      entry = timestamp + indent + message
      
      @stream ? puts(entry) : @log << entry
    end
    
    def run (event_name, runner)
      return runner.run if @disable
      
      write "#{event_name}..."
      @nest += 1
      
      start = Time.now
      runner.run
      elapsed = "%0.3fs" % (Time.now - start)
      
      @nest -= 1
      write "...[#{elapsed}]"
    end
  end
end
