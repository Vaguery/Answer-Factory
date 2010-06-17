module Schedule
  class TimedRun < Item
    def run
      expiration = Time.now.to_f + @limit
      
      begin
        logged_component_run
      end until Time.now.to_f > expiration
    end
  end
end
