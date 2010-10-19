require File.dirname(__FILE__) + '/../spec_helper'

class FakeMachine < Machine; end

describe Workstation do  
  describe "adding a machine" do
    before(:each) do
      workstation = Workstation.new('test')
      @machine = workstation.machine('sample', :FakeMachine)
    end
    
    it "names the machine's location as <workstation name>:<provided machine name>" do
      @machine.instance_variable_get("@location").should == 'test:sample'
    end
    
    it "sets the machine class as the provided class name" do
      @machine.class.should == FakeMachine
    end
  end
  
  it "adding a machine uses a the Machine base class if no class is provided" do
    workstation = Workstation.new('test')
    machine = workstation.machine('sample')
    machine.class.should == Machine
  end
  
  it "passes the config block to the machine initialzation if provided" do
    pending
    # config = lambda {}
    # 
    # mock_machine = mock('machine')
    # mock_machine.should_receive(:instance_eval).with(config)
    # Machine.should_receive(:new).with('test:sample').and_return(mock_machine)
    # 
    # workstation = Workstation.new('test')
    # machine = workstation.machine('sample', :Machine, &config)
  end
  
  describe "scheduled machines" do
    before(:each) do
      @workstation = Workstation.new('test')
    end
    
    describe "by default" do
      it "occur in the order defined in the configuration block" do
        @workstation.machine('zero', :FakeMachine)
        @workstation.machine('first', :FakeMachine)
        @workstation.instance_variable_get("@schedule").should == [:zero, :first]
      end
    end
    
    describe "being manually set" do
      it "occur as defined" do
        @workstation.machine('zero', :FakeMachine)
        @workstation.machine('first', :FakeMachine)
        @workstation.schedule :first, :zero
        @workstation.instance_variable_get("@schedule").should == [:first, :zero]
      end
    end
    
    describe "running" do
      it "runs each machine once in the scheduled order" do
        workstation = Workstation.new('test')
        zero = workstation.machine('zero', :FakeMachine)
        first = workstation.machine('first', :FakeMachine)
        
        zero.should_receive(:run).once.ordered
        first.should_receive(:run).once.ordered
        
        workstation.run
      end
    end
  end
end