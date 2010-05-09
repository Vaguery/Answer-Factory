#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::MutateFootnotesUniform" do
  before(:each) do
    @fiddler = Machines::MutateFootnotesUniform.new
    @two = Batch.[](
      Answer.new("value «int» \n«int» 1\n«bool» true"),
      Answer.new("block {value «code» value «float»} \n«code» value «bool» \n«bool» false\n«float» 0.00"))
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
    
    it "should not modify or include any Answer object in its argument Batch" do
      original_ids = @two.collect {|a| a.object_id}
      result_ids = @fiddler.build(@two).collect {|a| a.object_id}
      (original_ids & result_ids).length.should == 0
    end
    
    describe ":proportion_changed option" do
      it "should change a :proportion_changed of them, determined by a call option" do
        Nudge.should_receive(:const_defined?).exactly(5).times
        # one of the two footnotes will be mutated in each replicate
        @fiddler.build(Batch.[](@two[0]), proportion_changed:0.5, replicates:5)
      end
      
      it "should not change the values if the :proportion_changed is 0.0" do
        new_ones = @fiddler.build(@two, proportion_changed:0.0)
        (0..1).each {|i| @two[i].blueprint.should == new_ones[i].blueprint}
      end
      
      it "should change all the values if the :proportion_changed is 1.0" do
        new_ones = @fiddler.build(@two, proportion_changed:1.0)
        (0..1).each {|i| @two[i].blueprint.should_not == new_ones[i].blueprint}
      end
      
      it "should truncate the :proportion_changed value to the range [0.0,1.0]" do
        lambda{@fiddler.build(@two, proportion_changed:-12.0)}.should_not raise_error
        lambda{@fiddler.build(@two, proportion_changed:123.0)}.should_not raise_error
      end
      
      it "should use the initialization :proportion_changed option if there isn't a call option" do
        never = Machines::MutateFootnotesUniform.new(proportion_changed:0.0)
        Nudge.should_not_receive(:const_defined?)
        # if the default proportion (0.5) was used, it would randomize 5 times
        never.build(Batch.[](@two[0]), replicates:5)
      end
      
      it "should default to proportion_changed:0.5 if none was set as an option" do
        halvesies = Machines::MutateFootnotesUniform.new
        Nudge.should_receive(:const_defined?).exactly(5).times
        # if the default proportion (0.5) was used, it would randomize 5 times
        halvesies.build(Batch.[](@two[0]), replicates:5)
      end
    end
    
    
    describe ":replicates option" do
      it "should produce a :replicates for each arg Answer, determined by a call option" do
        @fiddler.build(@two, replicates:2).length.should == 2 * @two.length
      end
      
      it "should use the initialization :replicates option if there isn't a call option" do
        threefer = Machines::MutateFootnotesUniform.new(replicates:3)
        threefer.build(@two).length.should == 3*@two.length
      end
      
      it "should default to replicates:1 if none was set as an option" do
        @fiddler.build(@two).length.should == @two.length
      end
      
    end
  end
  
  
  describe "#mutated_footnote_value" do
    it "should call the appropriate NudgeType#any_value method" do
      IntType.should_receive(:any_value)
      @fiddler.mutated_footnote_value("«int» 1")
    end
    
    it "should return a string" do
      @fiddler.mutated_footnote_value("«int» 9").should be_a_kind_of(String)
    end
    
    it "should return a valid footnote string" do
      @fiddler.mutated_footnote_value("«int» 9").should =~ /«int» [-*\d+]/
    end
    
    it "should return the original, if the NudgeType isn't defined" do
      @fiddler.mutated_footnote_value("«foo» bar").should == "«foo» bar"
    end
    
    it "should pass through its merged options to the .any_value call" do
      @fiddler.mutated_footnote_value("«int» 9",
        randomIntegerLowerBound:77,
        randomIntegerUpperBound:77).should == "«int» 77"
    end
    
  end
end