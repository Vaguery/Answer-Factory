require File.join(File.dirname(__FILE__), "./../spec_helper")


describe AllDuplicatedGenomesSampler do
  before(:each) do
    @dg = AllDuplicatedGenomesSampler.new
  end
  
  
  describe "#generate" do
    before(:each) do
      @dudes = Batch[Answer.new("block {}"), Answer.new("block {}"), Answer.new("do int_add")]
    end
    
    it "should take a Batch as a first parameter" do
      lambda{@dg.generate()}.should raise_error(ArgumentError)
      lambda{@dg.generate(@dudes)}.should_not raise_error(ArgumentError)
    end

    it "should return a Batch" do
      @dg.generate(@dudes).should be_a_kind_of(Batch)
    end
    
    it "should return a Batch containing references to individuals in the original Batch" do
      repeats = @dg.generate(@dudes)
      repeats.length.should == 2
      repeats.each {|dude| @dudes.should include(dude)}
    end
    
    it "should return an empty Batch if there are no duplicates" do
      @dudes.delete_at(0)
      @dg.generate(@dudes).should be_empty
    end
  end
end