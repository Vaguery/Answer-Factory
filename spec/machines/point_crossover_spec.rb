#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::PointCrossover" do
  before(:each) do
    @mater = Machines::PointCrossover.new
    @two = Batch.[](
      Answer.new("block { do a do b do c do d}"),
      Answer.new("block { ref a ref b ref c ref d ref e}"))
  end
  
  
  describe "#build method" do
    it "should respond to :build" do
      @mater.should respond_to(:build)
    end
    
    it "should respond to :generate as an alias of :build" do
      @mater.should respond_to(:generate)
    end
    
    it "should raise an error if the argument isn't a Batch" do
      lambda{@mater.build(@two)}.should_not raise_error
      lambda{@mater.build(99)}.should raise_error
    end
    
    it "should produce a Batch" do
      @mater.build(@two).should be_a_kind_of(Batch)
    end
    
    it "should produce a Batch with a new object_id" do
      @mater.build(@two).object_id.should_not == @two.object_id
    end
    
    it "should not modify or include any Answer object from its argument Batch" do
      original_ids = @two.collect {|a| a.object_id}
      result_ids = @mater.build(@two).collect {|a| a.object_id}
      (original_ids & result_ids).length.should == 0
    end
    
    describe ":replicates option" do
      it "should produce :replicates offspring for each parent" do
        @mater.build(@two, replicates:2).length.should == 2 * @two.length
      end

      it "should use the initialization :replicates option if there isn't a call option" do
        threefer = Machines::PointCrossover.new(replicates:3)
        threefer.build(@two).length.should == 3*@two.length
      end
    
      it "should default to replicates:1 if none was set as an option" do
        @mater.build(@two).length.should == @two.length
      end
    end
    
    it "should increment the :progress attribute of the derived Answers, regardless of other settings" do
      @mater.build(@two).each {|a| a.progress.should == 1}
    end
    
    describe "crossing over code" do
      it "should work by selecting random pairs of parents (without replacement)" do
        @two.stub!(:sample).and_return([@two[0],@two[1]])
        @mater.build(@two)
      end
      
      it "should pick the exchanged points with uniform probability" do
        @two.stub!(:sample).and_return([@two[0],@two[1]])
        Kernel.should_receive(:rand).exactly(2).times.with(5).and_return(1)
        Kernel.should_receive(:rand).exactly(2).times.with(6).and_return(2)
        @mater.build(@two)
      end
      
      it "should move code from one parent to the other, for each offspring made" do
        Kernel.stub!(:rand).and_return(1)
        babies = @mater.build(@two)
        babies.each {|b| (b.blueprint.should include("ref")) && (b.blueprint.should include("do"))}
      end
    end
  end
end