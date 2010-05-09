require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::EvaluateSimpleScore" do
  describe "#score method" do
    
    before(:each) do
      @pointer = Machines::EvaluateSimpleScore.new(:name => :grault)
      @baa = Batch.[](Answer.new("do foo"), Answer.new("do quux"))
    end
    
    it "should respond to :score" do
      @pointer.should respond_to(:score)
    end
    
    it "should accept a Batch argument" do
      lambda{@pointer.score(9)}.should raise_error
      lambda{@pointer.score(Answer.new("foo"))}.should raise_error
      lambda{@pointer.score(Batch.new)}.should_not raise_error
    end
    
    it "should return a Batch" do
      @pointer.score(Batch.new).should be_a_kind_of(Batch)
    end
    
    it "should return the same Batch object_id it got" do
      @baa.object_id.should == @pointer.score(@baa).object_id
    end
    
    it "should return the same Answers in the arg" do
      @baa.each {|b| (@pointer.score(@baa).collect {|a| a.object_id}).should include(b.object_id)}
    end
    
    it "should accept a :name option in the call, and use that if it's present" do
      @pointer.score(@baa, :name => :foo)
      @baa.each {|a| a.scores.should include(:foo)}
    end
    
    it "should use a :name from the initialization options, if no call option overrides it" do
      Machines::EvaluateSimpleScore.new(:name => :bar).score(@baa)
      @baa.each {|a| a.scores.should include(:bar)}
    end
    
    it "should raise an error if no :name is available in either option Hash" do
      lambda{Machines::EvaluateSimpleScore.new.score(@baa)}.should raise_error(
          ArgumentError,
          "EvaluateSimpleScore: Undefined #name attribute")
    end
    
    it "should accept a block, which is what generates the score for an Answer" do
      (@baa.collect {|a| a.scores.include?(:grault)}).should == [false,false]
      @pointer.score(@baa) {|a| a.blueprint.length}
      (@baa.collect {|a| a.scores[:grault]}).should == [6,7]
    end
    
    it "should run a stored Proc if no block is given"
    
    it "should respect a :memoizable? option in the args if one is passed in" do
      pending
      @baa[0].scores[:grault] = 999
      @baa[1].scores[:grault] = 999
      @pointer.score(@baa, memoizable?:false) {|a| a.blueprint.length} # update scores
      @baa[0].scores[:grault].should == 6
      
      @baa[0].scores[:grault] = 999
      @baa[1].scores[:grault] = 999
      @pointer.score(@baa, memoizable?:true) {|a| a.blueprint.length} # update scores
      @baa[0].scores[:grault].should == 999
    end
    
    it "should fall back to the initialized :memoizable? option if not passed in"
    
    it "should fall back to a default of false if not set as an option"
    
    it "should not re-evaluate an Answer with a [non-nil] score, if :memoizable? is true"
    
    it "should write a new score to each Answer's #scores Hash"
  end
  
  it "should respond to :generate as an alias to :score" do
    Machines::EvaluateSimpleScore.new.should respond_to(:generate)
  end
end