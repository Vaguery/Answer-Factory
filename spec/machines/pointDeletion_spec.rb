require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "PointDeleteOperator search operator" do
  describe "generate" do
    before(:each) do
      @zapper = PointDeleteOperator.new()
      @dude1 = Answer.new("block { do thing1 \n do thing2 \n do thing3}")
    end
    
    it "should accept a Batch as a param" do
      lambda{@zapper.generate()}.should raise_error(ArgumentError)
      lambda{@zapper.generate(812)}.should raise_error(ArgumentError)
      lambda{@zapper.generate(Batch.new)}.should_not raise_error(ArgumentError)
      lambda{@zapper.generate(Batch[@dude1])}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an Argument error if all contents of the crowd aren't Answers" do
      lambda{@zapper.generate([])}.should_not raise_error(ArgumentError)
      lambda{@zapper.generate([ 77 ])}.should raise_error(ArgumentError)
      lambda{@zapper.generate([ @dude1, 77 ])}.should raise_error(ArgumentError)
    end
    
    it "should return a Batch as a result" do
      @zapper.generate([@dude1]).should be_a_kind_of(Batch)
    end
    
    it "should use Answer#delete_point to produce the variants" do
      @dude1.should_receive(:delete_point_or_clone).and_return("do parseable")
      @zapper.generate([@dude1])
    end
    
    it "should produce one result per individual in the wildtype crowd as a default" do
      @zapper.generate([@dude1]).length.should == 1
      @zapper.generate([@dude1, @dude1]).length.should == 2
    end
    
    it "should produce more if passed the optional howManyCopies parameter > 1" do
      @zapper.generate([@dude1],2).length.should == 2
      @zapper.generate([@dude1, @dude1],3).length.should == 6
    end
    
    it "should produce individuals from which a random point (and its subpoints) is deleted" do
      @zapper.generate([@dude1],5).each {|baby| baby.points.should < @dude1.points}
    end
    
    it "should produce 'block {}' whenever a root is deleted" do
      @zapper.should_receive(:rand).with(4).and_return(0)
      @zapper.generate([@dude1])[0].blueprint.should == "block {}"
    end
    
    it "should increment the progress of the offspring" do
      @dude1.stub(:progress).and_return(195)
      @zapper.generate([@dude1])[0].progress.should == 196
    end
    
    it "should handle moving the footnotes correctly"
    
    it "should maintain unused footnotes correctly"
    
  end
end