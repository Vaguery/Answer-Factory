#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../../spec_helper")


describe TestCase do
  describe "bindings" do
    it "should have a Hash of independent variable names and assigned values" do
      TestCase.new.should respond_to(:bindings)
    end
  end
  
  describe "expectations" do
    it "should have a Hash of dependent variable names and expected values" do
      TestCase.new.should respond_to(:expectations)
    end
  end
  
  describe "gauges" do
    it "should have a Hash of Proc objects that measure the observed values" do
      TestCase.new.should respond_to(:gauges)
    end
    
    it "should have one gauge for every expectation" do
      lambda{TestCase.new(
        :expectations => {"y1"=>ValuePoint.new("int", 31)},
        :gauges => {"h"=>Proc.new {} } )}.should raise_error
      lambda{TestCase.new(
        :expectations => {"y1"=>ValuePoint.new("int", 31)},
        :gauges => {"y1"=>Proc.new {} } )}.should_not raise_error
    end
  end
end





describe TestCaseEvaluator do
  describe "initialize" do
    it "should have a name" do
      lambda{TestCaseEvaluator.new()}.should raise_error(ArgumentError)
      lambda{TestCaseEvaluator.new(name:"boolean_multiplexer_SSE")}.should_not raise_error
    end
    
    it "should have all the info it needs to set up an Interpreter"
  end
  
  describe "evaluate" do
    before(:each) do
      @tce = TestCaseEvaluator.new(:name => :error)
      @dudes = Batch[
        Answer.new("value «int»\n«int» 12"),
        Answer.new("value «int»\n«int» -9912"),
        Answer.new("value «bool»\n«bool» false"),
        Answer.new("block { value «int» value «int»}\n«int» 99\n«int» 12")
      ]
      @cases = [
        TestCase.new(:bindings => {"x" => ValuePoint.new("int",77)},
          :expectations => {"y" => 12},
          :gauges => {"y" => Proc.new {|interp| interp.stacks[:int].peek}}
        ),
        TestCase.new(:bindings => {"x" => ValuePoint.new("int",78)},
          :expectations => {"y" => 13},
          :gauges => {"y" => Proc.new {|interp| interp.stacks[:int].peek}}
        )
      ]
    end
    
    it "should raise an exception if the batch argument isn't a Batch" do
      lambda{@tce.evaluate()}.should raise_error(ArgumentError)
      lambda{@tce.evaluate(@dudes)}.should_not raise_error(ArgumentError)
    end
    
    it "should assign a numeric score to all the Answers in the Batch" do
      @dudes.each {|dude| dude.scores[:error].should == nil}
      @tce.evaluate(@dudes, @cases)
      @dudes.each {|dude| dude.scores[:error].kind_of?(Numeric).should == true}
    end
    
    it "should create an Interpreter for each run" do
      myI = Interpreter.new
      Interpreter.should_receive(:new).exactly(8).times.and_return(myI)
      @tce.evaluate(@dudes, @cases)
    end
    
    it "should be reset each time before running them" do
      myI = Interpreter.new
      Interpreter.stub!(:new).and_return(myI)
      myI.should_receive(:reset).exactly(8).times
      @tce.evaluate(@dudes, @cases)
    end
    
    it "should set up bindings before running them" do
      myI = Interpreter.new
      Interpreter.stub!(:new).and_return(myI)
      myI.should_receive(:bind_variable).exactly(8).times
      @tce.evaluate(@dudes, @cases)
    end
    
    it "should run each TestCase for each individual in the Batch" do
      myI = Interpreter.new
      Interpreter.stub!(:new).and_return(myI)
      myI.should_receive(:run).exactly(8).times
      @tce.evaluate(@dudes, @cases)
    end
    
    it "after running a TestCase using an Answer, all the gauges should be called" do
      myI = Interpreter.new
      Interpreter.stub!(:new).and_return(myI)
      myI.should_receive(:run).exactly(8).times
      @tce.evaluate(@dudes, @cases)
      
      myI.should_receive(:run).exactly(4).times
      @tce.evaluate(@dudes, [TestCase.new(:gauges => {"a" => Proc.new {|interp|}})])
    end
    
    it "should synthesize the gauge readings into a single numerical score"
    
    it "should loop over the test cases to collect the error" do
      @dudes.each {|dude| dude.scores[:error].should == nil}
      
      @tce.evaluate(@dudes, @cases)
      equal12or13error = @dudes.collect {|dude| dude.scores[:error]}
      expectedScores = [1, 19849, 200000, 1]
      (0..3).each {|i| equal12or13error[i].should be_close(expectedScores[i].to_f / 2, 0.0001)}
    end
    
  end
end