require 'answer_factory'

describe "Workstation" do
  describe ".new (name: Symbol)" do
    it "sets @name to name.to_sym" do
      workstation = Workstation.new(:w)
      workstation.instance_variable_get(:@name).should == :w
    end
    
    it "sets @machines to {}" do
      workstation = Workstation.new(:w)
      workstation.instance_variable_get(:@machines).should == {}
    end
    
    it "sets @schedule to []" do
      workstation = Workstation.new(:w)
      workstation.instance_variable_get(:@schedule).should == []
    end
    
    it "inserts the new workstation into the Factory::Workstations hash" do
      workstation = Workstation.new(:w)
      Factory::Workstations[:w].should == workstation
    end
    
    it "calls #setup on the new workstation" do
      workstation = Workstation.new(:w)
      workstation.should_receive(:setup)
      workstation.send(:initialize, :w)
    end
    
    it "executes the configuration block" do
      lambda { Workstation.new(:w) { raise "x" } }.should raise_error "x"
    end
  end
  
  describe "#schedule (*machine_names: Symbol, *)" do
    it "stores the given machine names in @schedule" do
      workstation = Workstation.new(:w)
      workstation.schedule :a, :b, :c
      workstation.instance_variable_get(:@schedule).should == [:a, :b, :c]
    end
  end
  
  describe "#run" do
    it "returns nil immediately if @schedule is empty" do
      workstation = Workstation.new(:w)
      workstation.instance_variable_set(:@schedule, [])
      
      workstation.run.should == nil
    end
    
    it "calls #run on each machine named in @schedule" do
      workstation = Workstation.new(:w)
      m1 = mock(:m1)
      m2 = mock(:m2)
      workstation.instance_variable_set(:@machines, {:m1 => m1, :m2 => m2})
      workstation.instance_variable_set(:@schedule, [:m1, :m2])
      
      Factory.stub!(:load_answers).and_return([])
      Factory.stub!(:save_answers)
      
      m1.should_receive(:run)
      m2.should_receive(:run)
      
      workstation.run
    end
    
    it "raises Factory::MachineMissing if @schedule contains a machine_name that lacks a corresponding machine" do
      workstation = Workstation.new(:w)
      workstation.instance_variable_set(:@schedule, [:m])
      
      Factory.stub!(:load_answers)
      
      lambda { workstation.run }.should raise_error Factory::MachineMissing, "no machine named :m"
    end
  end
  
  describe "#dump (machine_name: Symbol)" do
    it "returns an array containing the answers associated with machine_name in @answers_by_machine" do
      workstation = Workstation.new(:w)
      a1 = mock(:a1)
      a2 = mock(:a2)
      workstation.instance_variable_set(:@answers_by_machine, {:m => [a1, a2]})
      
      workstation.dump(:m).should == [a1, a2]
    end
    
    it "removes the answers from the array associated with machine_name in @answers_by_machine" do
      workstation = Workstation.new(:w)
      a1 = mock(:a1)
      a2 = mock(:a2)
      workstation.instance_variable_set(:@answers_by_machine, {:m => [a1, a2]})
      
      workstation.dump(:m)
      
      workstation.instance_variable_get(:@answers_by_machine).should == {:m => []}
    end
  end
  
  describe "#reassign" do
    it "" do
      pending :'write spec'
    end
  end
end
