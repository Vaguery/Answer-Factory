require File.dirname(__FILE__) + '/../spec_helper'

describe Machine do
  describe "adding a route" do
    it "appends to existing routes" do
      machine = Machine.new("location")
      machine.instance_variable_get("@routes").should == {}
    
      machine.send :best => :someplace
      machine.instance_variable_get("@routes").should == {:best => :someplace}
    
      machine.send :rest => :someplace_else
      machine.instance_variable_get("@routes").should == {:best => :someplace, :rest => :someplace_else}
    end    
  end
  
  describe "processing answers" do
    it "raises NoMethodError if process_answers is undefined and no process block is provided during configuration" do
      machine = Machine.new("location")
      lambda { machine.process_answers}.should raise_error(NoMethodError)
    end
    
    it "defaults to calling the process_answers" do
      machine = Machine.new("location")
      machine.should_receive(:process_answers)
      
      machine.instance_variable_get("@process").call
    end
  end
  
  it "returns answers keyed by language" do
    machine = Machine.new("location")
    
    answer_0 = Answer.new(FakeBlueprint.new)
    answer_1 = Answer.new(FakeBlueprint.new)
    answer_2 = Answer.new(NudgeBlueprint.new("block {}"))
    
    machine.instance_variable_set("@answers", [answer_0, answer_1, answer_2])
    
    machine.answers_keyed_by_language.should == {
      :Fake => [answer_0, answer_1],
      :Nudge => [answer_2]
    }
  end
  
  describe "loading assocaited scores from database" do
    before(:each) do
      @machine = Machine.new('name')
    end
    it "defaults to yes" do
      @machine.instance_variable_get("@load_scores").should == true
    end
    
    it "can be overwritten" do
      @machine.load_without_scores(true)
      @machine.instance_variable_get("@load_scores").should == false
    end
  end
  describe "run" do
    before(:each) do
      @best_answer = Answer.new(FakeBlueprint.new)
      @rest_answer = Answer.new(FakeBlueprint.new)
      
      Factory.stub!(:save_answers, true)
      Factory.stub!(:load_answers, [@best_answer, @rest_answer])
      
      @machine = Machine.new("location")
      @machine.send :best => :best_place, :rest => :rest_place
      @machine.process do
        {:best => [@best_answer], :rest => [@rest_answer]}
      end
    end
    
    it "loads answers for this location from the database" do
      Factory.should_receive(:load_answers).with("location", true)
      Factory.stub!(:save_answers, true)
      @machine.run
    end
    
    it "process answers" do
      @machine.instance_variable_get("@process").should_receive(:call).and_return({})
      @machine.run
    end
    
    it "raises SomeError if answers processing does not return a route pattern as hash" do
      @machine.instance_variable_get("@process").should_receive(:call).and_return(false)
      lambda { @machine.run }.should raise_error(Machine::SomeError)
    end
    
    it "stores the new locations into each answer" do
      @machine.run
      
      @best_answer.instance_variable_get("@location").should == :best_place
      @rest_answer.instance_variable_get("@location").should == :rest_place
    end
    
    it "saves the answers to the database" do
      Factory.should_receive(:save_answers)
      @machine.run
    end
  end
end