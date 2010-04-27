#encoding:utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "random_guess operator" do
  before(:each) do
    @myGuesser = RandomGuessOperator.new
  end
  
  it "should be a kind of SearchOperator" do
    @myGuesser.should be_a_kind_of(SearchOperator)
  end
  
  it "should have a params attribute when created that sets basic values for code generation" do
    RandomGuessOperator.new.incoming_options.should == {}
    thisGuesser = RandomGuessOperator.new(foo:99, bar:101)
    thisGuesser.incoming_options.should_not == {}
    thisGuesser.incoming_options[:foo].should == 99
  end
  
  
  it "should produce a Batch of Answers when it receives #generate" do
    newDudes = @myGuesser.generate
    newDudes.should be_a_kind_of(Batch)
    newDudes[0].should be_a_kind_of(Answer)
    newDudes[0].blueprint.should_not == nil
    newDudes[0].program.should_not == nil
  end
  
  it "should produce one as a default, more if a higher number is passed in" do
    @myGuesser.generate.length.should == 1
    @myGuesser.generate(4).length.should == 4
  end
  
  it "should have a parsed blueprint as its #program attribute" do
    newDudes = @myGuesser.generate
    newDudes[0].program.should be_a_kind_of(NudgeProgram)
  end
  
  it "should accept temporarily overriding options to pass into CodeType.any_value" do
    @myNewGuesser = RandomGuessOperator.new(
      target_size_in_points: 7,
      instruction_names: ["int_add", "int_subtract"],
      reference_names: ["x1", "x2", "x3"])
      
    lambda{@myNewGuesser.generate(
      3,
      target_size_in_points: 12,
      reference_names: ["y1"])}.should_not raise_error
      
    @myNewGuesser.generate(
      3,
      target_size_in_points: 12)[0].program.points.should_not == 7
      
    @myNewGuesser.generate(
      3,
      target_size_in_points: 12)[0].program.points.should == 12
      
    @myNewGuesser.generate(
      1,
      target_size_in_points: 16,
      probabilities:{b:0,r:1,v:0,i:0},
      reference_names: ["y1"])[0].blueprint.should include("y1")
  end
  
  it "should produce a Batch that contains Answers with progress=0 only" do
    @myGuesser.generate(12).each {|dude| dude.progress.should == 0}
  end
  
  it "should handle generated footnotes correctly" do
    @myGuesser.generate(1,
      target_size_in_points: 52,
      type_names:["int"],
      probabilities: {b:0,v:1,i:0,r:0})[0].program.footnote_section.scan(/«int»/).length.should == 51
  end
  
end