require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::SelectNondominated" do
  describe "#screen method" do
    before(:each) do
      @best = Machines::SelectNondominated.new
      @highlander = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
      @highlander[0].scores = {e1:5, e2:15}
      @highlander[1].scores = {e1:15,e2:5}
      @highlander[2].scores = {e1:1, e2:1}
      
      @lowlander = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
      @lowlander[0].scores = {e1:1, e2:3}
      @lowlander[1].scores = {e1:2, e2:2}
      @lowlander[2].scores = {e1:3, e2:1}
      
      @allover = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
      @allover[0].scores = {e1:1, e2:3}
      @allover[1].scores = {e1:2, e2:2, e3:2}
      @allover[2].scores = {e1:3}
    end
    
    it "should respond to :screen" do
      @best.should respond_to(:screen)
    end
    
    it "should only accept a Batch as its argument" do
      lambda{@best.screen(129)}.should raise_error
      lambda{@best.screen([Answer.new("foo")])}.should raise_error
      lambda{@best.screen(@highlander)}.should_not raise_error
    end
    
    it "should produce a Batch" do
      @best.screen(@highlander).should be_a_kind_of(Batch)
    end
    
    it "should accept a template Array of score keys" do
      @best.screen(@lowlander).length.should == 3
      @best.screen(@lowlander,comparison_criteria:[:e2]).length.should == 1
    end
    
    it "should use an initialization template as well" do
      specialized_result = Machines::SelectNondominated.new(comparison_criteria:[:e2]).screen(@lowlander)
      specialized_result.length.should == 1
      specialized_result[0].scores.should == {e1:3, e2:1}
    end
    
    it "should override its initialization if given a #build option" do
      overriden = Machines::SelectNondominated.new(comparison_criteria:[:e2]).
        screen(@lowlander,comparison_criteria:[:e1])
      overriden.length.should == 1
      overriden[0].scores.should == {e1:1, e2:3}
    end
    
    it "should assume Answers with nonidentical keys are mutually nondominated" do
      @best.screen(@allover, comparison_criteria:[:e1]).length.should == 1
      @best.screen(@allover, comparison_criteria:[:e2]).length.should == 2
      @best.screen(@allover, comparison_criteria:[:e3]).length.should == 3
    end
    
    it "should return the nondominated subset of the argument" do
      @best.screen(@highlander).length.should == 1
      @best.screen(@highlander)[0].scores.should == {e1:1, e2:1}
    end
    
    it "should return objects from the argument, not clones" do
      (@highlander.collect {|a| a.object_id}).should include(@best.screen(@highlander)[0].object_id)
    end
    
    it "should return a new Batch object" do
      @best.screen(@highlander).object_id.should_not == @highlander.object_id
    end
  end
  
  it "should respond to :generate as an alias to :screen" do
    Machines::SelectNondominated.new.should respond_to(:generate)
  end
end

