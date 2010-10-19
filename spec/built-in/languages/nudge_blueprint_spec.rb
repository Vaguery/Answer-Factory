# encoding: UTF-8
require 'spec_helper'


describe "#points" do
  it "should return the number of program points in the compiled code tree" do
    NudgeBlueprint.new("ref x").points.should == 1
    NudgeBlueprint.new("block{ref x}").points.should == 2
  end
  
  it "should work as expected with programs containing NilPoints" do
    pending "not broken, just confused by assumptions in other parts of the codebase"
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


describe "#delete_n_points_at_random" do
  it "should remove 1 point at random from large trees" do
    mom = NudgeBlueprint.new("block { ref a ref b ref c}") # 4 points
    Random.should_receive(:rand).with(3).and_return(0)
    mom.delete_n_points_at_random(1).should match_script("block { ref b ref c }")
  end
  
  it "should delete the root of 1-point programs and return an empty block" do
    pending "broken"
    mom = NudgeBlueprint.new("ref a")
    mom.delete_n_points_at_random(1).should match_script("block {}") # not a NilPoint
  end
  
  it "should be robust to over-deletion by returning an empty block if everything goes" do
    pending "broken"
    mom = NudgeBlueprint.new("block { ref a ref b ref c}")
    mom.delete_n_points_at_random(12).should match_script("block {}") # not a NilPoint
  end
  
  it "should update the point count between iterations of deletion" do
    mom = NudgeBlueprint.new("block { block {ref b ref c} ref a}")
    Random.should_receive(:rand).with(4).ordered.and_return(1)
    Random.should_receive(:rand).with(3).ordered.and_return(0)
      # to work, this needs to re-count points between iterations
    
    mom.delete_n_points_at_random(2).should match_script("block {ref a}")
  end
end


describe "insert_n_points_at_random" do
  it "should convert a 1-point program into a block" do
    pending "broken"
    mom = NudgeBlueprint.new("ref a")
    Object.should_receive(:random).and_return("do nothing_important")
    mom.insert_n_points_at_random(1,Object).should match_script("block { ref b ref c }")
  end
  
  it "should insert a point into a 2-point program"
  
  it "should create a new random point for every point it inserts"
  
  it "should work in a reasonable way if you insert 20 things into a 10-point program"
  
  it "should not insert points into other points it has inserted (????)"
  # for example http://gist.github.com/635378
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