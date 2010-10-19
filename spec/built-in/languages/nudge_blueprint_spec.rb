# encoding: UTF-8
require 'spec_helper'


describe "#points" do
  it "should return the number of program points in the compiled code tree" do
    NudgeBlueprint.new("ref x").points.should == 1
    NudgeBlueprint.new("block{ref x}").points.should == 2
  end
  
  it "should work as expected with programs containing NilPoints" do
    pending "broken by assumptions other parts of the codebase"
    contains_a_nil = BlockPoint.new(RefPoint.new("x"), NilPoint.new("foo")) # 2 points
    NudgeBlueprint.new(contains_a_nil.to_script).points.should == contains_a_nil.points
  end
end


describe "blending_crossover" do
  it "should build answers by sampling (1...count_of_all_points) times" do
    mom = NudgeBlueprint.new("block{do a}")
    dad = NudgeBlueprint.new("block{do b}")
    
    Random.should_receive(:rand).with(2).and_return(0)
    mom.blending_crossover(dad)
  end
  
  it "should use the parents' roots if they are not blocks" do
    mom = NudgeBlueprint.new("ref x")
    dad = NudgeBlueprint.new("do y")
    
    Random.should_receive(:rand).with(2).and_return(0)
    mom.blending_crossover(dad)
  end
  
  it "should sample top level points from the parents" do
    mom = NudgeBlueprint.new("block {do a block {do b} do c }") # 3 top level points
    dad = NudgeBlueprint.new("block {ref x block {ref y} block{ref z}}") # 3 top level points
    Random.should_receive(:rand).with(6).and_return(1000) #  max it out so it samples all points
    
    baby = mom.blending_crossover(dad).strip
    baby.should =~ /do a/
    baby.should_not =~ /[^{] do b/ # should not disassemble top level points
    baby.should =~ /do c/
    baby.should =~ /ref x/
    baby.should_not =~ /[^{] ref y/
    baby.should_not =~ /[^{] ref z/ 
  end
  
  it "should fail gracefully with NilPoints" do
    mom = NudgeBlueprint.new("FIRP")
    dad = NudgeBlueprint.new("DING")
    Random.should_receive(:rand).with(2).and_return(1000) # max it out so it samples all points
    mom.blending_crossover(dad).should =~ /((FIRP|DING)\s){2}/
  end
end


describe "#wrap_block" do
  it "should wrap the root for all 1-point programs" do
    pending "broken"
    NudgeBlueprint.new("do a").wrap_block.should match_script("block { do a }")
    NudgeBlueprint.new("block {}").wrap_block.should match_script("block { block {} }")
    
  end
  
  it "should [appear to] wrap the root for all 2-point programs" do
    pending "broken"
    NudgeBlueprint.new("block {do a}").wrap_block.should match_script("block {block { do a }}")
  end
  
  it "should sometimes wrap some or all of the top level for 3+ point programs" do
    pending "broken"
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {block {do a do b}}")
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {block {do a} do b}")
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {do a block {do b}}")
  end
  
end