require File.join(File.dirname(__FILE__), "./../spec_helper")


describe MostDominatedSubsetSampler do
  before(:each) do
    @md = MostDominatedSubsetSampler.new
  end
    
  
  describe "#generate" do
    before(:each) do
      @dudes = Batch[Answer.new("block {}"), Answer.new("block {}"), Answer.new("block {}")]
      @dudes[0].scores = Hash[:first, 2,   :second, 20,  :third, 200]
      @dudes[1].scores = Hash[:first, 20,  :second, 200, :third, 2]
      @dudes[2].scores = Hash[:first, 200, :second, 2,   :third, 20]
    end
    
    it "should take a Batch as a first parameter" do
      lambda{@md.generate()}.should raise_error(ArgumentError)
      lambda{@md.generate(@dudes)}.should_not raise_error(ArgumentError)
    end

    it "should return a Batch" do
      @md.generate(@dudes).should be_a_kind_of(Batch)
    end
    
    it "should return a Batch containing references to individuals in the original Batch" do
      half = @md.generate(@dudes)
      half.length.should be > 0
      half.each {|dude| @dudes.should include(dude)}
    end
    
    it "should always return at least one, even when everybody is nondominated" do
      some = @md.generate(@dudes)
      some.length.should == 3
      some.each {|dude| @dudes.should include(dude)}
    end
    
    
    it "should take a template of objectives to use in sorting" do
      @md.generate(@dudes,[:first]).should include(@dudes[2])
      @md.generate(@dudes,[:second]).should include(@dudes[1])
      @md.generate(@dudes,[:second, :third]).should include(@dudes[0])
    end
  end
  
end