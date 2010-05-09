#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::VaryValuesUniformly" do
  before(:each) do
    @fiddler = Machines::VaryValuesUniformly.new
    @two = Batch.[](Answer.new("value «int»\n«int»12"),Answer.new("value «bool»\n«bool» false"))
  end
  
  describe "#build method" do
    it "should respond to :build" do
      @fiddler.should respond_to(:build)
    end
    
    it "should respond to :generate as an alias of :build" do
      @fiddler.should respond_to(:generate)
    end
    
    it "should raise an error if the argument isn't a Batch" do
      lambda{@fiddler.build(@two)}.should_not raise_error
      lambda{@fiddler.build(99)}.should raise_error
    end
    
    it "should produce a Batch" do
      @fiddler.build(@two).should be_a_kind_of(Batch)
    end
    
    it "should produce a Batch with a new object_id" do
      @fiddler.build(@two).object_id.should_not == @two.object_id
    end
    
    it "should not modify or include any Answer object in its argument Batch" do
      original_ids = @two.collect {|a| a.object_id}
      result_ids = @fiddler.build(@two).collect {|a| a.object_id}
      (original_ids & result_ids).length.should == 0
    end
    
    it "should change one or more footnotes of each argument Answer"
    
    describe ":proportion_changed option" do
      it "should change a :proportion_changed of them, determined by a call option"
      
      it "should truncate the :proportion_changed value to the range [0.0,1.0]"
      
      it "should use the initialization :proportion_changed option if there isn't a call option"
      
      it "should default to proportion_changed:0.5 if none was set as an option"
    end
    
    
    describe "Nudge options" do
      
      it "should invoke the given footnotes' NudgeType.any_value method"
      
      it "should pass through its merged options to the .any_value call"
      
    end
    
    
    describe ":number_of_variants option" do
      it "should produce a :number_of_variants for each arg Answer, determined by a call option"
      
      it "should use the initialization :number_of_variants option if there isn't a call option"
      
      it "should default to number_of_variants:1 if none was set as an option"
      
    end
  end
end