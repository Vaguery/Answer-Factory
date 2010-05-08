require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::SampleAnyOne" do
  before(:each) do
    @sampler = Machines::SampleAnyOne.new
    @two = Batch.[](Answer.new("do a"),Answer.new("do b"))
  end
  
  
  describe "#generate method" do
    it "should respond to #generate" do
      @sampler.should respond_to(:generate)
    end

    it "should have arity 1" do
      @sampler.method(:generate).arity.should == 1
    end
    
    it "should validate the argument is a Batch" do
      lambda{@sampler.generate(89)}.should raise_error(ArgumentError)
    end
    
    it "should return a Batch" do
      @sampler.generate(@two).should be_a_kind_of(Batch)
    end
    
    it "should return an empty batch if passed an empty one" do
      @sampler.generate(Batch.new).length.should == 0
    end
    
    it "should return a Batch with one element if passed any" do
      @sampler.generate(@two).length.should == 1
    end
    
    it "should contain a direct reference to an object in the argument Batch" do
      (@two.collect {|a| a.object_id}).should include(@sampler.generate(@two)[0].object_id)
    end
    
  end
end