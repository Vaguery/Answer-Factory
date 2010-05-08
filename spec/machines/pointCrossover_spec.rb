require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "PointCrossoverOperator" do
  before(:each) do
    @myXover = PointCrossoverOperator.new
    @dude1 = Answer.new("block{do a \n do b\n do c}")
    @dude2 = Answer.new("block{ref x \n ref y\n ref z}")
  end
  
  it "should be a kind of SearchOperator" do
    @myXover.should be_a_kind_of(SearchOperator)
  end
  
  
  describe "generate" do
    
    it "should take as a param a set of one or more Answers" do
      lambda{@myXover.generate()}.should raise_error(ArgumentError)
      lambda{@myXover.generate(331)}.should raise_error(ArgumentError)
      lambda{@myXover.generate([])}.should raise_error(ArgumentError)
      lambda{@myXover.generate([11])}.should raise_error(ArgumentError)
      
      lambda{@myXover.generate([@dude1])}.should_not raise_error(ArgumentError)
    end
    
    it "should produce the same number of Answers it gets as a default" do
      babies = @myXover.generate([@dude1])
      babies.length.should == 1
    end
          
    it "should have an optional parameter that specifies the number of offspring to produce per parent" do
      babies = @myXover.generate(Batch.[](@dude1, @dude2))
      babies.length.should == 2
      babies = @myXover.generate([@dude1, @dude2],4)
      babies.length.should == 8
    end
    
    it "should only include points from one of the parents in the offspring blueprints" do
      babies = @myXover.generate([@dude1, @dude2])
      bothGenomes = @dude1.program.blueprint + @dude2.program.blueprint
      babies.each do |baby|
        baby.program.blueprint.each_line do |line|
          bothGenomes.match(line.strip.delete("}")).should_not == nil
        end
      end
    end
    
    it "should handle moving the footnotes correctly"
    
    it "should maintain unused footnotes correctly"
    
    it "should increment the offspring's progress from the max parents' progress" do
      @dude1.stub(:progress).and_return(7)
      @dude2.stub(:progress).and_return(11)
      babies = @myXover.generate([@dude1, @dude2],10)
      babies.each {|baby| [8,12].should include(baby.progress)}
    end
    
    it "should return a Batch" do
      babies = @myXover.generate(Batch.[](@dude1, @dude2))
      babies.should be_a_kind_of(Batch)
    end
  end
end