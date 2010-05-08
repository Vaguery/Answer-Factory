require File.join(File.dirname(__FILE__), "./../spec_helper")

describe AnyOneSampler do
  before(:each) do
    @ao = AnyOneSampler.new
  end
  
  
  describe "#generate" do
    before(:each) do
      @dudes = Batch[Answer.new(""), Answer.new(""), Answer.new("")]
      @dudes[0].scores = Hash["first", 2,   "second", 20,  "third", 200]
      @dudes[1].scores = Hash["first", 20,  "second", 200, "third", 2]
      @dudes[2].scores = Hash["first", 200, "second", 2,   "third", 20]
    end
    
    it "should take a Batch as a first parameter" do
      lambda{@ao.generate()}.should raise_error(ArgumentError)
      lambda{@ao.generate(@dudes)}.should_not raise_error(ArgumentError)
    end

    it "should return a Batch" do
      @ao.generate(@dudes).should be_a_kind_of(Batch)
    end
    
    it "should return a Batch containing references to Answers in the original Batch" do
      one = @ao.generate(@dudes)
      one.length.should == 1
      one.each {|dude| @dudes.should include(dude)}
    end
    
    it "should invoke Batch#sample" do
      @dudes.should_receive(:sample).and_return(@dudes[0])
      one = @ao.generate(@dudes)
    end
    
  end
  
end