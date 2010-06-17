module Schedule
  class CountedRun < Item
    def run
      @limit.times do
        logged_component_run
      end
    end
  end
end
