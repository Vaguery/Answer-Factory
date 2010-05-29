#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::MutateCodeblock" do
  before(:each) do
    @twiddler = Machines::MutateCodeblock.new
    @two = Batch.[](
      Answer.new("value «int» \n«int» 1"),
      Answer.new("block { block {value «code»} ref x1 block { block {ref x2}}} \n«code» value «bool» \n«bool» false"))
  end
  
  
  describe "#build method" do
    it "should respond to :build" do
      @twiddler.should respond_to(:build)
    end
    
    it "should respond to :generate as an alias of :build" do
      @twiddler.should respond_to(:generate)
    end
    
    it "should raise an error if the argument isn't a Batch" do
      lambda{@twiddler.build(@two)}.should_not raise_error
      lambda{@twiddler.build(99)}.should raise_error
    end
    
    it "should produce a Batch" do
      @twiddler.build(@two).should be_a_kind_of(Batch)
    end
    
    it "should produce a Batch with a new object_id" do
      @twiddler.build(@two).object_id.should_not == @two.object_id
    end
    
    it "should not modify or include any Answer object from its argument Batch" do
      original_ids = @two.collect {|a| a.object_id}
      result_ids = @twiddler.build(@two).collect {|a| a.object_id}
      (original_ids & result_ids).length.should == 0
    end
    
    describe ":replicates option" do
      it "should produce a :replicates for each arg Answer, determined by a call option" do
        @twiddler.build(@two, replicates:2).length.should == 2 * @two.length
      end

      it "should use the initialization :replicates option if there isn't a call option" do
        threefer = Machines::MutateCodeblock.new(replicates:3)
        threefer.build(@two).length.should == 3*@two.length
      end
    
      it "should default to replicates:1 if none was set as an option" do
        @twiddler.build(@two).length.should == @two.length
      end
    end
    
    it "should increment the :progress attribute of the derived Answers, regardless of other settings" do
      @twiddler.build(@two).each {|a| a.progress.should == 1}
    end
    
    describe "mutating code" do
      before(:each) do
        @some_code = ReferencePoint.new(:abcde)
      end
      
      it "should replace one program point in each mutant"
      
      it "should pick the replaced point with uniform probability" do
        CodeType.should_receive(:any_value).exactly(2).times.and_return(@some_code)
        @twiddler.build(@two)
      end
      
      it "should replace a point with one that's the same size if :size_preserving? is true" do
        Kernel.should_not_receive(:rand)
        new_dudes = @twiddler.build(@two, size_preserving?:true)
        new_dudes.each_with_index {|a,idx| a.points.should == @two[idx].points}
      end
      
      it "should replace a point with one between 1 and 2xsize if :sizepreserving? is false" do
        Kernel.stub!(:rand).and_return(17)
        CodeType.should_receive(:any_value).at_least(2).times.
          with(hash_including(size_preserving?:false,target_size_in_points:18)).and_return(@some_code)
        @twiddler.build(@two, size_preserving?:false)
      end
            
      it "should pass all options through to the any_value call" do
        Kernel.stub!(:rand).and_return(3)
        CodeType.should_receive(:any_value).at_least(2).times.
          with(hash_including(target_size_in_points:4, foo:12)).and_return(@some_code)
        @twiddler.build(@two, foo:12)
      end
    end
  end
end