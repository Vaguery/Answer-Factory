require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::SampleAnyOne" do
  before(:each) do
    @sampler = Machines::SampleAnyOne.new
    @two = Batch.[](Answer.new("do a"),Answer.new("do b"))
  end
  
  describe "#screen method" do
    it "should respond to #screen" do
      @sampler.should respond_to(:screen)
    end

    it "should have arity 1" do
      @sampler.method(:screen).arity.should == 1
    end
    
    it "should validate the argument is a Batch" do
      lambda{@sampler.screen(89)}.should raise_error(ArgumentError)
    end
    
    it "should return a Batch" do
      @sampler.screen(@two).should be_a_kind_of(Batch)
    end
    
    it "should return an empty batch if passed an empty one" do
      @sampler.screen(Batch.new).length.should == 0
    end
    
    it "should return a Batch with one element if passed any" do
      @sampler.screen(@two).length.should == 1
    end
    
    it "should contain a direct reference to an object in the argument Batch" do
      (@two.collect {|a| a.object_id}).should include(@sampler.screen(@two)[0].object_id)
    end
    
  end
  
  
  describe "#generate alias" do
    it "should fire #screen in response to #generate" do
      @sampler.generate(@two).length.should == 1
    end
  end
end


describe "Machines::RemoveAnyOne" do
  before(:each) do
    @sampler = Machines::RemoveAnyOne.new
    @three = Batch.[](Answer.new("do a"),Answer.new("do b"), Answer.new("do c"))
  end
  
  describe "#screen method" do
    it "should respond to #screen" do
      @sampler.should respond_to(:screen)
    end

    it "should have arity 1" do
      @sampler.method(:screen).arity.should == 1
    end
    
    it "should validate the argument is a Batch" do
      lambda{@sampler.screen(89)}.should raise_error(ArgumentError)
    end
    
    it "should return a Batch" do
      @sampler.screen(@three).should be_a_kind_of(Batch)
    end
    
    it "should return an empty batch if passed an empty one" do
      @sampler.screen(Batch.new).length.should == 0
    end
    
    it "should not change the original Batch argument" do
      @sampler.screen(@three).object_id.should_not == @three.object_id
    end
    
    it "should return a Batch with one fewer elements" do
      @sampler.screen(@three).length.should == 2
    end
        
    it "should contain direct references to all but one objects in the argument Batch" do
      removed = @sampler.screen(@three)
      id3 = @three.collect {|a| a.object_id}
      idr = removed.collect {|b| b.object_id}
      
      idr.each {|b| id3.should include(b)}
      (id3 - idr).length.should == 1
    end
  end
  
  
  describe "#generate alias" do
    it "should fire #screen in response to #generate" do
      @sampler.generate(@three).length.should == 2
    end
  end
end