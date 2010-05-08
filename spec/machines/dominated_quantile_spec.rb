require File.join(File.dirname(__FILE__), "./../spec_helper")


describe DominatedQuantileSampler do
  before(:each) do
    @dq = DominatedQuantileSampler.new
  end
  
  
  describe "domination_classes" do
    before(:each) do
      @dudes = Batch[Answer.new("block {}"), Answer.new("do int_add")]
      @dudes[0].scores["first"] = 120
      @dudes[1].scores["first"] = 2
      @dudes[0].scores["second"] = 2
      @dudes[1].scores["second"] = 120
      @dudes[0].scores["third"] = 20
      @dudes[1].scores["third"] = 1200
    end
    
    it "should take a Batch as an argument" do
      lambda{@dq.domination_classes()}.should raise_error(ArgumentError)
      lambda{@dq.domination_classes(@dudes)}.should_not raise_error(ArgumentError)
      
    end
    
    it "can take a template of objective names to use" do
      lambda{@dq.domination_classes(@dudes, ["first"])}.should_not raise_error(ArgumentError)
    end
    
    it "should return a Hash" do
      @dq.domination_classes(@dudes, ["first"]).should be_a_kind_of(Hash)
    end
    
    it "should use the count of dominating Answers as the key" do
      @dq.domination_classes(@dudes, ["second"]).keys.should == [0,1]
      @dq.domination_classes(@dudes).keys.should == [0]
      
    end
    
    it "should have an Array of the Answers in that class as the value" do
      @dq.domination_classes(@dudes, ["first"])[0].length.should == 1
      @dq.domination_classes(@dudes, ["first"])[0][0].should == @dudes[1]
      @dq.domination_classes(@dudes, ["second"])[0].length.should == 1
      @dq.domination_classes(@dudes, ["second"])[0][0].should == @dudes[0]
      @dq.domination_classes(@dudes, ["second", "third"])[0].length.should == 1
      @dq.domination_classes(@dudes, ["second", "third"])[0][0].should == @dudes[0]
    end
  end
  
  
  describe "#generate" do
    before(:each) do
      @dudes = Batch[Answer.new("do int_subtract"), Answer.new("do int_add")]
      @dudes[0].scores["first"] = 120
      @dudes[1].scores["first"] = 2
      @dudes[0].scores["second"] = 2
      @dudes[1].scores["second"] = 120
      @dudes[0].scores["third"] = 20
      @dudes[1].scores["third"] = 1200
    end
    
    it "should take a Batch as a first parameter" do
      lambda{@dq.generate()}.should raise_error(ArgumentError)
      lambda{@dq.generate(@dudes)}.should_not raise_error(ArgumentError)
    end

    it "should return a Batch" do
      @dq.generate(@dudes).should be_a_kind_of(Batch)
    end
    
    it "should return a Batch containing references to individuals in the original Batch" do
      half = @dq.generate(@dudes)
      half.length.should be > 0
      half.each {|dude| @dudes.should include(dude)}
    end
    
    it "should have a parameter that specifies what fraction to return" do
      some = @dq.generate(@dudes,1.0)
      some.length.should == 2
      
      some = @dq.generate(@dudes,0.5)
      some.length.should == 1
    end
    
    it "should always return at least one for a non-zero fraction" do
      some = @dq.generate(@dudes,0.01)
      some.length.should be > 0
      some.each {|dude| @dudes.should include(dude)}
      
      some = @dq.generate(@dudes,0)
      some.length.should == 0
    end
    
    
    it "should take a template of objectives to use in sorting" do
      @dq.generate(@dudes,0.5,["first"]).should include(@dudes[0])
      @dq.generate(@dudes,0.5,["second"]).should include(@dudes[1])
      @dq.generate(@dudes,0.5,["second", "third"]).should include(@dudes[1])
    end
    
    it "should return the most-dominated Answers first, nondominated last" do
      some = @dq.generate(@dudes,1, ["first"])
      some[0].should == @dudes[0]
      
      some = @dq.generate(@dudes,1, ["second"])
      some[0].should == @dudes[1]
    end
  end
  
end