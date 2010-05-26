require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::SelectBySummedRank" do
  before(:each) do
    @best = Machines::SelectBySummedRank.new
    @highlander = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
    @highlander[0].scores = {e1:15, e2:12}  # 3,3 = 6
    @highlander[1].scores = {e1:5,  e2:5}   # 2,2 = 4
    @highlander[2].scores = {e1:1,  e2:1}   # 1,1 = 2
    
    @lowlander = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
    @lowlander[0].scores = {e1:1, e2:3} # 1,3 = 4
    @lowlander[1].scores = {e1:2, e2:2} # 2,2 = 4
    @lowlander[2].scores = {e1:3, e2:1} # 3,1 = 4
    
    @allover = Batch.[](Answer.new("foo"), Answer.new("bar"), Answer.new("baz"))
    @allover[0].scores = {e1:1, e2:3}         # 1,2,- 
    @allover[1].scores = {e1:2, e2:2, e3:2}   # 2,1,1 
    @allover[2].scores = {e1:3}               # 3,-,- 
    
    @separate = Batch.[](Answer.new("foo"), Answer.new("bar"))
    @separate[0].scores = {e1:1}
    @separate[1].scores = {e2:2, e3:2}
  end
  
  
  describe "#screen method" do
    it "should respond to :screen" do
      @best.should respond_to(:screen)
    end
    
    it "should only accept a Batch as its argument" do
      lambda{@best.screen(129)}.should raise_error
      lambda{@best.screen([Answer.new("foo")])}.should raise_error
      lambda{@best.screen(@highlander, comparison_criteria:[:e1])}.should_not raise_error
    end
    
    it "should produce a Batch" do
      @best.screen(@highlander, comparison_criteria:[:e2]).should be_a_kind_of(Batch)
    end
    
    it "should use the :comparison_criteria option as a template Array of score keys" do
      ignore_most = @best.screen(@lowlander, comparison_criteria:[:e1])
      ignore_most.length.should == 1
      ignore_most.should include(@lowlander[0])
      
      ignore_most = @best.screen(@lowlander, comparison_criteria:[:e2])
      ignore_most.length.should == 1
      ignore_most.should include(@lowlander[2])
      
      ignore_most = @best.screen(@allover, comparison_criteria:[:e1])
      ignore_most.length.should == 1
      ignore_most.should include(@allover[0])
    end
    
    it "should use the intersection of all the score keys in the :batch as a default for criteria" do
      @best.should_receive(:shared_goals).and_return([:e1])
      @best.screen(@highlander)
    end
    
    it "should accept (and store) an initialization :comparison_criteria option" do
      just_one = Machines::SelectBySummedRank.new(comparison_criteria:[:e2]).
        screen(@lowlander)
      just_one.length.should == 1
      just_one.should include(@lowlander[2])
    end
    
    it "should include all Answers lacking a given score (since they can't be ranked)" do
      dunno = @best.screen(@allover, comparison_criteria:[:e2])
      dunno.length.should == 2
      dunno.should include(@allover[1])
      dunno.should include(@allover[2])
      dunno.should_not include(@allover[0])
    end
    
    it "should return the entire batch if no scores are shared" do
      @best.screen(@separate).length.should == 2
    end
    
    it "should override its initialization if given a #build option" do
      overridden = Machines::SelectBySummedRank.new(comparison_criteria:[:e2]).
        screen(@lowlander,comparison_criteria:[:e1])
      overridden.length.should == 1
      overridden[0].scores.should == {e1:1, e2:3}
    end
    
    it "should return the lowest-ranking subset of the argument Batch" do
      @best.screen(@lowlander).length.should == 3
    end
    
    it "should return objects from the argument, not clones" do
      (@highlander.collect {|a| a.object_id}).should include(@best.screen(@highlander)[0].object_id)
    end
    
    it "should return a new Batch object" do
      @best.screen(@highlander).object_id.should_not == @highlander.object_id
    end
    
    it "should not change the :progress of the Answers" do
      @best.screen(@highlander).each {|a| a.progress.should == 0}
    end
    
  end
  
  
  it "should respond to :generate as an alias to :screen" do
    Machines::SelectBySummedRank.new.should respond_to(:generate)
  end
  
  
  describe "all_goals" do
    it "should return an Array of score keys" do
      @best.all_goals(@highlander).should == [:e1,:e2]
    end
    
    it "should include every score key in the batch passed in" do
      @best.all_goals(@allover).should == [:e1,:e2, :e3]
    end
    
    it "should have one copy of each score name" do
      @best.all_goals(@highlander).find_all {|e| e == :e1}.length.should == 1
    end
  end
  
  
  describe "shared_goals" do
    it "should return an Array of only the shared score keys from the Batch passed in" do
      @best.shared_goals(@highlander).should == [:e1,:e2]
      @best.shared_goals(@allover).should == [:e1]
      @best.shared_goals(@separate).should == []
    end
  end
end

