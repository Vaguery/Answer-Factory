#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::VaryValuesUniformly" do
  before(:each) do
    @fiddler = Machines::VaryValuesUniformly.new
    @two = Batch.[](Answer.new("value «int»\n«int»12"),Answer.new("value «bool»\n«bool» false"))
  end
  
  describe "#build method" do
    it "should respond to :build" do
      @fiddler.should respond_to(:build)
    end
    
    it "should respond to :generate as an alias of :build" do
      @fiddler.should respond_to(:generate)
    end
    
    it "should raise an error if the argument isn't a Batch" do
      lambda{@fiddler.build(@two)}.should_not raise_error
      lambda{@fiddler.build(99)}.should raise_error
    end
    
    it "should produce a Batch" do
      @fiddler.build(@two).should be_a_kind_of(Batch)
    end
    
    it "should produce a Batch with a new object_id" do
      @fiddler.build(@two).object_id.should_not == @two.object_id
    end
    
    it "should not modify any Answer object in its argument Batch"
    
    
    describe ":how_many option" do
      
    end
    
    
    describe "Nudge options" do
      
    end
    
    
  end
end