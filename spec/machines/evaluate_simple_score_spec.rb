require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::EvaluateSimpleScore" do
  describe "#score method" do
    
    before(:each) do
      @pointer = Machines::EvaluateSimpleScore.new(
        :name => :grault,
        scorer:Proc.new {0})
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
      Machines::EvaluateSimpleScore.new(:name => :bar).score(@baa) {2}
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
    
    it "should run a stored :scorer Proc initialization option if no block is given" do
      @baa.each {|a| @pointer.options[:scorer].should_receive(:call).with(a)}
      @pointer.score(@baa)
    end
    
    it "should raise an error if no :scorer block is available in either option Hash" do
      lambda{Machines::EvaluateSimpleScore.new.score(@baa,name:"a")}.should raise_error(
          ArgumentError,
          "EvaluateSimpleScore: No scoring block available")
    end
    
    it "should respect a :static_score? option in the args if one is passed in" do
      @baa[0].scores[:grault] = 999
      @pointer.score(@baa, static_score?:false) {|a| a.blueprint.length} # update scores
      @baa[0].scores[:grault].should == 6
      
      @baa[0].scores[:grault] = 999
      @pointer.score(@baa, static_score?:true) {|a| a.blueprint.length} # update scores
      @baa[0].scores[:grault].should == 999
    end
    
    it "should fall back to the initialized :static_score? option if not passed in" do
      zero = Machines::EvaluateSimpleScore.new(
        :name => :zero,
        scorer:Proc.new {0},
        static_score?:true)
        
      zero.score(@baa) # set up scores
      zero.score(@baa) {12}
      @baa[0].scores[:zero].should == 0
      zero.score(@baa, static_score?:false) {12}
      @baa[0].scores[:zero].should == 12
    end
    
    it "should fall back to a default of false if not set as an option" do
      one = Machines::EvaluateSimpleScore.new(
        :name => :one,
        scorer:Proc.new {1})
      one.score(@baa)
      one.score(@baa) {2}
      @baa[0].scores[:one].should == 2
    end
    
    it "should write a new score to each Answer's #scores Hash" do
      @baa.each {|a| a.scores.should_receive(:[]=).with(:two,2)}
      @pointer.score(@baa, :name => :two) {2}
    end
  end
  
  it "should respond to :generate as an alias to :score" do
    Machines::EvaluateSimpleScore.new.should respond_to(:generate)
  end
end