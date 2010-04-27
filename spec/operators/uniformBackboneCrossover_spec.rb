require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "UniformBackboneCrossoverOperator" do
  before(:each) do
    @newDudes = []
    @options = {target_size_in_points: 6, instruction_names: ["a", "b", "c"], type_names: ["int"]}
    @myXover = UniformBackboneCrossoverOperator.new
    @myGuesser = RandomGuessOperator.new(@options)
  end
  
  it "should be a kind of SearchOperator" do
    @myXover.should be_a_kind_of(SearchOperator)
  end
  
  it "should produce a Batch of Answers when it receives #generate" do
    @newDudes = @myXover.generate(@myGuesser.generate(2))
    @newDudes.should be_a_kind_of(Batch)
    @newDudes.each {|dude| dude.should be_a_kind_of(Answer)}
  end
  
  it "should produce the same number of Answers it gets as a default" do
    @newDudes = @myXover.generate(@myGuesser.generate(6))
    @newDudes.length.should == 6
  end
  
  it "should have an optional parameter that specifies the number of offspring to produce" do
    @newDudes = @myXover.generate(@myGuesser.generate(2),5)
    @newDudes.length.should == 5
  end
  
  it "should only include backbone points from one of the parents in the offsprings' genomes" do
    rents = @myGuesser.generate(2)
    @newDudes = @myXover.generate(rents,1)
    @newDudes.length.should == 1
    allParentalPoints = rents[0].program[1].contents + rents[1].program[1].contents
    allTidied = allParentalPoints.collect {|pt| "#{pt.tidy}<br />"}
  end
  
  it "should return an identical individual if given only one parent" do
    rent = @myGuesser.generate(1)
    @newDudes = @myXover.generate(rent,3)
    @newDudes.each {|kid| kid.program.tidy.should == rent[0].program.tidy}
  end
  
  
  it "should not affect the original parents set in any way" do
    rents = @myGuesser.generate(2)
    originalMom = rents[0].object_id
    @newDudes = @myXover.generate(rents,1)
    rents[0].object_id.should == originalMom
  end
  
  it "should return offspring with #progress values incremented from the largest parent value" do
    rents = @myGuesser.generate(2)
    rents[0].should_receive(:progress).at_least(1).times.and_return(12)
    rents[1].should_receive(:progress).at_least(1).times.and_return(33)
    @newDudes = @myXover.generate(rents,20)
    @newDudes.each {|baby| [13, 34].should include(baby.progress)}
  end
  
  it "should handle moving the footnotes correctly"
  
  it "should maintain unused footnotes correctly"
  
  
end