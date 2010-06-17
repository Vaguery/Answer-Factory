require 'answer_factory'

Scheduler = Object.new.send(:extend, Schedule)

class Scheduled
  attr_reader :name
  
  def initialize (name)
    @name = name
    Scheduler.components[name] = self
  end
end

Scheduled.new(:a)
Scheduled.new(:b)
Scheduled.new(:c)

describe "Schedule" do
  describe "#schedule" do
    describe "(*)" do
      it "clears any previously scheduled items" do
        Scheduler.schedule(:a, :b, :c)
        Scheduler.instance_variable_get(:@schedule).length.should === 3
        
        Scheduler.schedule(:c)
        Scheduler.instance_variable_get(:@schedule).length.should === 1
      end
      
      it "stores CountedRun and TimedRun items in the schedule" do
        counted_run = Schedule::CountedRun.new(5, :a)
        timed_run = Schedule::TimedRun.new(3, :b)
        
        Scheduler.schedule(counted_run, timed_run)
        
        Scheduler.instance_variable_get(:@schedule)[0].should === counted_run
        Scheduler.instance_variable_get(:@schedule)[1].should === timed_run
      end
    end
    
    describe "(item_name: Symbol, *)" do
      it "stores symbol names as CountedRun items of limit (1)" do
        Scheduler.schedule(:a)
        Scheduler.instance_variable_get(:@schedule)[0].instance_variable_get(:@limit).should === 1
      end
    end
    
    describe "(item: Array, *)" do
      it "stores arrays of the format [:item_name, \"\#{N}x\"] as CountedRun items of limit (N.to_i)" do
        Scheduler.schedule([:a, "5x"])
        Scheduler.instance_variable_get(:@schedule)[0].instance_variable_get(:@limit).should === 5
      end
      
      it "stores arrays of the format [:workstation_id, \"\#{T}s\"] as TimedRun items of limit (T.to_f)" do
        Scheduler.schedule([:a, "60s"], [:b, "1.0m"], [:c, "0.0166666666666666666667h"])
        Scheduler.instance_variable_get(:@schedule)[0].instance_variable_get(:@limit).should === 60.0
      end
    
      it "stores arrays of the format [:workstation_id, \"\#{T}m\"] as TimedRun items of limit (T.to_f * 60)" do
        Scheduler.schedule([:a, "60s"], [:b, "1.0m"], [:c, "0.0166666666666666666667h"])
        Scheduler.instance_variable_get(:@schedule)[1].instance_variable_get(:@limit).should === 60.0
      end
    
      it "stores arrays of the format [:workstation_id, \"\#{T}h\"] as TimedRun items of limit (T.to_f * 60 * 60)" do
        Scheduler.schedule([:a, "60s"], [:b, "1.0m"], [:c, "0.0166666666666666666667h"])
        Scheduler.instance_variable_get(:@schedule)[2].instance_variable_get(:@limit).should === 60.0
      end
    end
  end
end
