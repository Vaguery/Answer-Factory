# encoding: UTF-8
require File.expand_path("../../answer_factory", File.dirname(__FILE__))

describe "Machine" do
  describe ".new (name: Symbol, workstation: Workstation)" do
    it "sets @name to name.to_sym" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.instance_variable_get(:@name).should == :m
    end
    
    it "sets @workstation to workstation" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.instance_variable_get(:@workstation).should == workstation
    end
    
    it "sets @path to {}" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.instance_variable_get(:@path).should == {}
    end
    
    it "raises ArgumentError if workstation is not a Workstation" do
      workstation = Object.new
      lambda { Machine.new(:w, workstation) }.should raise_error ArgumentError,
        "machine requires an instance of Workstation"
    end
    
    it "inserts the new machine into the workstation's @machines hash" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      workstation.instance_variable_get(:@machines).should == {:m => machine}
    end
  end
  
  describe ".new (name: Symbol, workstation: Workstation) {|machine| config }" do
    it "executes the configuration block" do
      workstation = Workstation.new(:w)
      lambda { Machine.new(:m, workstation) { raise "x" } }.should raise_error "x"
    end
  end
  
  describe "#path" do
    it "returns @path" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.path.should == {}
    end
  end
  
  describe "#run" do
    it "dumps this machine's workstation's answers" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      workstation.should_receive(:dump).with(:m).and_return([])
      machine.stub!(:process).and_return({})
      
      machine.run
    end
    
    it "processes the dumped answers" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      answers = [mock(:answers)]
      
      answers.stub!(:length).and_return(0)
      workstation.stub!(:dump).and_return(answers)
      
      machine.should_receive(:process).with(answers).and_return({})
      
      machine.run
    end
    
    it "reassigns the output answers according to the hash returned by #process" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      answers = mock(:answers)
      
      machine.path[:path] = :w, :n
      
      answers.stub!(:length).and_return(0)
      workstation.stub!(:dump).and_return(answers)
      machine.stub!(:process).and_return({:path => answers})
      
      workstation.should_receive(:reassign).with(answers, :w, :n)
      
      machine.run
    end
  end
  
  describe "#average_gain (path_name: Symbol)" do
    it "divides the #total_answers_out for this path by total_answers_in" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.instance_variable_set(:@total_answers_in, 100)
      machine.instance_variable_set(:@total_answers_out,{foo:172})
      machine.average_gain(:foo).should == 1.72
    end
  end
  
  describe "#method_missing (method_name: Symbol, *args)" do
    it "sets an instance variable when method_name is an attr_set id" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      machine.method_missing(:foo=, 1)
      
      machine.instance_variable_get(:@foo).should == 1
    end
    
    it "raises NoMethodError when method_name is not an attr_set id" do
      workstation = Workstation.new(:w)
      machine = Machine.new(:m, workstation)
      
      lambda { machine.method_missing(:foo) }.should raise_error NoMethodError
    end
  end
end
