require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "resample_and_clone operator" do
  before(:each) do
    @myGuesser = RandomGuessOperator.new(type_names: ["int"], instruction_names: ["int_add"])
    @mySampler = ResampleAndCloneOperator.new
  end
  
  it "should be a kind of SearchOperator" do
    @mySampler.should be_a_kind_of(SearchOperator)
  end

  it "should produce a list of Answers when it receives #generate" do
    newDudes = @mySampler.generate(@myGuesser.generate(3))
    newDudes.should be_a_kind_of(Batch)
    newDudes[0].should be_a_kind_of(Answer)
    newDudes[0].blueprint.should_not == nil
    newDudes[0].program.should_not == nil
  end
  
  it "should produce one Answer with a blueprint identical to one of the passed in crowd's" do
    pop = @myGuesser.generate(1)
    newDudes = @mySampler.generate(pop)
    newDudes[0].blueprint.should == pop[0].blueprint
  end
  
  it "should return more than one individual when asked to, resampling as needed" do
    newDudes = @mySampler.generate(@myGuesser.generate(10))
    newDudes.length.should == 1
    newDudes = @mySampler.generate(@myGuesser.generate(3),2)
    newDudes.length.should == 2
    newDudes = @mySampler.generate(@myGuesser.generate(1),2)
    newDudes.length.should == 2
    newDudes[0].blueprint.should == newDudes[1].blueprint
  end
  
  it "should not return links to the original program copies in the new clones" do
    pop = @myGuesser.generate(3)
    newDudes = @mySampler.generate(pop)
    pop.collect {|old_dude| old_dude.program.object_id}.should_not include(newDudes[0].program.object_id)
  end
  
  it "should have a parsed blueprint as its #program attribute" do
    pop = @myGuesser.generate(3)
    newDudes = @mySampler.generate(pop)
    newDudes[0].program.should be_a_kind_of(NudgeProgram)
  end
  
  it "should increment the #progress of each clone" do
    pop = @myGuesser.generate(3)
    pop.each {|donor| donor.stub(:progress).and_return(12)}
    newDudes = @mySampler.generate(pop)
    newDudes.each {|kid| kid.progress.should == 13}
  end
  
  it "should handle footnotes correctly"
  
  it "should use a deep copy to clone new guys, not just clone"
end