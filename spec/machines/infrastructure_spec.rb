require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "domination_classes" do
  before(:each) do
    @dq = Sampler.new
    
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
