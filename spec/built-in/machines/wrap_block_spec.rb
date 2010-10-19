require 'spec_helper'

describe "#create convenience method" do
  it "should set the @number_to_create attribute" do
    spec_machine = WrapBlock.new(:here)
    spec_machine.create 7
    spec_machine.instance_variable_get(:@number_to_create).should == 7
  end
end


describe "#process_answers" do
  before(:each) do
    Factory.stub!(:save_answers)
    @spec_machine = WrapBlock.new(:here)
    @dummy_answer = Answer.new(NudgeBlueprint.new("block{do foo do bar do baz}"))
  end
  
  
  it "should make @number_to_create variants for each answer it starts with" do
    @spec_machine.create 7
    
    @spec_machine.should_receive(:answers).
      at_least(1).times.and_return([@dummy_answer])
    
    output_hash = @spec_machine.process_answers
    
    # by convention, result is {path_for_originals: old_answers, path_for_new_ones: new_answers}
    (output_hash.values[0].length * 7).should == output_hash.values[1].length
  end
  
  
  it "should call the [Language].wrap_block method once for each original answer" do
    @spec_machine.create 3
    
    @spec_machine.should_receive(:answers).
      at_least(1).times.and_return([@dummy_answer])
    
    @dummy_answer.blueprint.should_receive(:wrap_block).
      exactly(3).times.and_return(NudgeBlueprint.new("nothing"))
    
    output_hash = @spec_machine.process_answers
  end
  
  
  it "should send the old and new answers along its two output routes" do
    @spec_machine.should_receive(:answers).
      at_least(1).times.and_return([@dummy_answer])
    
    output_hash = @spec_machine.process_answers
    
    # by convention, result is {path_for_originals: old_answers, path_for_new_ones: new_answers}
    output_hash.values[0].should include(@dummy_answer)
    output_hash.values[1].should_not include(@dummy_answer)
  end
  
  
  it "should always modify the blueprints of the answers it makes" do
    pending "broken in NudgeBlueprint#wrap_block"
    @spec_machine.create 100
    @spec_machine.should_receive(:answers).
      at_least(1).times.and_return([@dummy_answer])
    output_hash = @spec_machine.process_answers
    output_hash.values[1].each {|answer| answer.blueprint.
      should_not match_script(@dummy_answer.blueprint)}
  end
end