require 'answer_factory'

describe "Workstation" do
  describe ".new (name: Symbol)" do
    it "stores the new workstation in the Factory singleton's components" do
      w = Workstation.new(:w)
      
      Factory.instance_variable_get(:@components)[:w].should == w
    end
    
    it "calls #setup on the created workstation" do
      w = Workstation.new(:w)
      
      w.should_receive(:setup)
      w.send(:initialize, :w)
    end
    
    describe "{|w| config }" do
      it "evaluates the configuration block, passing the created workstation as w" do
        w = Workstation.new(:w)
        
        w.should_receive(:object_id)
        w.send(:initialize, :w) {|w| w.object_id }
      end
    end
  end
  
  describe "#run" do
    it "returns immediately if the schedule is empty" do
      w = Workstation.new(:w)
      
      w.instance_variable_set(:@schedule, [])
      
      w.run
    end
    
    it "calls run on each item in the schedule once per cycle" do
      w = Workstation.new(:w)
      
      w.stub!(:load_answers_and_distribute_to_machines!)
      w.stub!(:save_answers!)
      
      item_1 = mock(:schedule_item)
      item_2 = mock(:schedule_item)
      
      item_1.stub!(:component_name)
      
      item_1.should_receive(:run).exactly(4).times
      item_2.should_receive(:run).exactly(8).times
      
      w.instance_variable_set(:@cycles, 4)
      w.instance_variable_set(:@schedule, ([item_1, item_2, item_2]))
      
      w.run
    end
    
    it "begins by loading answers and distributing them to machines" do
      pending "figure out how to spec this"
    end
    
    it "finishes by saving answers" do
      pending "figure out how to spec this"
    end
  end
end
