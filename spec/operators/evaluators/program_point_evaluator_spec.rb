require File.join(File.dirname(__FILE__), "./../../spec_helper")


describe ProgramPointEvaluator do
  
  describe "initialization" do
    it "should have an objective name set upon initialization" do
      lambda{ProgramPointEvaluator.new}.should raise_error(ArgumentError)
    end
  end
  
  describe "#evaluate" do
    before(:each) do
      @ppe = ProgramPointEvaluator.new(:score_label => :point_count)
      @dudes = Batch[
        Answer.new("block {}"),
        Answer.new("block { block {}}"),
        Answer.new("block { block { block {}}}")
      ]
    end
    
    it "should take a Batch of individuals as an argument" do
      lambda{@ppe.evaluate(Answer.new("block {}"))}.should raise_error(ArgumentError)
      lambda{@ppe.evaluate(Batch[Answer.new("block {}")])}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an exception if it can't evaluate an Answer" do
      lambda{@ppe.evaluate(Batch[Answer.new("blah_de_blah")])}.should raise_error(ArgumentError)
    end
    
    it "should write the number of program points into each individual" do
      @dudes.each {|dude| dude.scores[:point_count].should == nil}
      @ppe.evaluate(@dudes)
      @dudes.collect {|dude| dude.scores[:point_count]}.should == [1,2,3]
    end
    
    it "should return the same Batch it got, with updated values" do
      origIDs = @dudes.collect {|dude| dude.object_id}
      @ppe.evaluate(@dudes)
      @dudes.each {|dude| origIDs.should include(dude.object_id)}
    end
  end
end