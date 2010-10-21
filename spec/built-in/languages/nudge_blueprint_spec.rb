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


describe "script string" do
  it "should be robust to round trips between point and text modes" do
    pending "broken"
    NudgePoint.from("ref a").to_script.should == NudgeBlueprint.new("ref a")
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
    pending "edge case never specified clearly in features"
    mom = NudgeBlueprint.new("ref a")
    mom.delete_n_points_at_random(1).should match_script("block {}") # not a NilPoint
  end
  
  it "should be robust to over-deletion by returning an empty block if everything goes" do
    pending "never specified"
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
  
  it "should be robust to the presence of NilPoints"
end


describe "insert_n_points_at_random" do
  it "should convert a 1-point program into a block" do
    pending "never mentioned"
    mom = NudgeBlueprint.new("ref a")
    Object.should_receive(:random).and_return("do nothing_important")
    mom.insert_n_points_at_random(1,Object).should match_script("block { ref b ref c }")
  end
  
  it "should insert a point into a 3-point program" do
    pending "method signature NudgePoint#insert_point_after doesn't match what's sent"
    mom = NudgeBlueprint.new("block {ref a ref b}")
    puts mom.insert_n_points_at_random(1,NudgeWriter.new)
  end
  
  it "should create a new random point for every point it inserts"
  
  it "should work in a reasonable way if you insert 20 things into a 10-point program"
  
  it "should not insert points into other points it has inserted (????)"
  # for example http://gist.github.com/635378
  
  it "should be robust to the presence of NilPoints"
end


describe "#mutate_n_points_at_random" do
  it "should replace the entirety of a 1-point script [but maybe with the same script]" do
    mom = NudgeBlueprint.new("ref a")
    dumb_writer = NudgeWriter.new
    dumb_writer.stub!(:random).and_return("I DID IT")
    mom.mutate_n_points_at_random(1,dumb_writer).strip.should == "I DID IT"
  end
  
  it "should change the root or a leaf" do
    mom = NudgeBlueprint.new("block {do change_this}")
    dumb_writer = NudgeWriter.new
    dumb_writer.stub!(:random).and_return("XXXXX")
    
    Random.should_receive(:rand).exactly(2).times.with(2).and_return(0,1)
    mom.mutate_n_points_at_random(1,dumb_writer).strip.should == "XXXXX"
    mom.mutate_n_points_at_random(1,dumb_writer).strip.should == "block { XXXXX }"
  end
  
  it "should pick n different points in the original script to change (?????)"
  
  it "shouldn't mutate a point that is already part of a previous mutation (?????)"
  
  it "should be robust to large numbers of repeated mutations"
  
  it "should be robust to the presence of NilPoints"
end


describe "#mutate_n_values_at_random" do
  it "should change the footnote but not root of a 1-point value script" do
    mom = NudgeBlueprint.new("value «int» \n«int» 12")
    dumb_writer = NudgeWriter.new
    mom.mutate_n_values_at_random(1,dumb_writer).strip.should match(/value «int»\n«int»/)
  end
  
  it "should call the method for a random value for each value changed" do
    mom = NudgeBlueprint.new("block {value «int» value «bool»} \n«int» 12\n«bool»false")
    dumb_writer = NudgeWriter.new
    dumb_writer.should_receive(:generate_value).with(:int)
    dumb_writer.should_receive(:generate_value).with(:bool)
    mom.mutate_n_values_at_random(2,dumb_writer)
  end
  
  it "should change the values in a random order" do
    pending "broken"
    mom = NudgeBlueprint.new("block {value «int» value «int»} \n«int» 1\n«int»2")
    dumb_writer = NudgeWriter.new
    10.times.collect {mom.mutate_n_values_at_random(1,dumb_writer).
      include?("«int»1")}.should include(false)
  end
  
  it "should be robust to over-mutation" do
    mom = NudgeBlueprint.new("value «int» \n«int» 12")
    dumb_writer = NudgeWriter.new
    lambda { mom.mutate_n_values_at_random(22,dumb_writer) }.should_not raise_error
  end
  
  it "should skip unknown value types" do
    pending "never specified"
    mom = NudgeBlueprint.new("value «foo» \n«foo» meep")
    dumb_writer = NudgeWriter.new
    lambda{ mom.mutate_n_values_at_random(22,dumb_writer) }.should_not raise_error
  end
  
  it "should be robust to the presence of NilPoints"
end


describe "#point_crossover" do
  it "should return an Array of two new scripts" do
    NudgeBlueprint.new("ref a").point_crossover(NudgeBlueprint.new("do y")).length.should == 2
  end
  
  it "should just swap the scripts of two 1-point programs" do
    mom = NudgeBlueprint.new("ref a")
    dad = NudgeBlueprint.new("do y")
    Random.should_receive(:rand).with(1).exactly(2).times.and_return(0)
    kids = mom.point_crossover(dad)
    kids.should include "ref a\n"
    kids.should include "do y\n"
  end
  
  it "should be possible to swap the root of one parent for a point in the other" do
    mom = NudgeBlueprint.new("ref a")
    dad = NudgeBlueprint.new("block {do x do y do z}")
    Random.should_receive(:rand).with(1).ordered.and_return(0)
    Random.should_receive(:rand).with(4).ordered.and_return(2)
    kids = mom.point_crossover(dad)
    kids[0].should match_script("do y")
    kids[1].should match_script("block {do x ref a do z}")
  end
  
  it "should work correctly with complex footnotes" do
    mom = NudgeBlueprint.new("value «code»\n«code»value «int»\n«int» 8")
    dad = NudgeBlueprint.new("block {do x do y do z}")
    Random.should_receive(:rand).with(1).ordered.and_return(0)
    Random.should_receive(:rand).with(4).ordered.and_return(2)
    kids = mom.point_crossover(dad)
    kids[0].should match_script("do y")
    kids[1].should match_script("block { do x value «code» do z }\n«code»value «int»\n«int»8")
  end
  
  it "should be robust to the presence of NilPoints" do
    pending "was never specified"
    mom = NudgeBlueprint.new("foo bar")
    dad = NudgeBlueprint.new("block {do x do y do z}")
    Random.should_receive(:rand).with(1).ordered.and_return(0)
    Random.should_receive(:rand).with(4).ordered.and_return(2)
    kids = mom.point_crossover(dad)
    kids[0].should match_script("?????")
    kids[1].should match_script("?????")
  end
end


describe "#unwrap_block" do
  it "should not change a blockless script" do
    NudgeBlueprint.new("ref a").unwrap_block.should match_script("ref a")
    NudgeBlueprint.new("ref a").unwrap_block.points.should == 1
  end
  
  it "should not unwrap the root of a multipoint script" do
    NudgeBlueprint.new("block {ref a}").unwrap_block.should match_script("block {ref a}")
    NudgeBlueprint.new("block {ref a}").unwrap_block.points.should == 2
  end
  
  it "should select a block from anywhere in the script to unwrap, with equal probability" do
    pending "does not randomly sample points"
    mom = NudgeBlueprint.new("block {block { block {ref a} block {block{ref b}}}}") # 7 points
    variants = 10.times.collect {mom.unwrap_block}
    variants.collect {|v| v.points}.uniq.should == [6]
    variants.uniq.length.should_not == 1
  end
  
  it "should be robust to the presence of NilPoints"
end

describe "#wrap_block" do
  it "should wrap the root for all 1-point programs" do
    pending "never mentioned"
    NudgeBlueprint.new("do a").wrap_block.should match_script("block { do a }")
    NudgeBlueprint.new("block {}").wrap_block.should match_script("block { block {} }")
  end
  
  it "should [appear to] wrap the root for all 2-point programs" do
    pending "?"
    NudgeBlueprint.new("block {do a}").wrap_block.should match_script("block {block { do a }}")
  end
  
  it "should sometimes wrap some or all of the top level for 3+ point programs" do
    pending "?"
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {block {do a do b}}")
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {block {do a} do b}")
    # stub Random.rand appropriately
    NudgeBlueprint.new("block {do a do b}").wrap_block.should match_script("block {do a block {do b}}")
  end
  
  it "should be robust to the presence of NilPoints"
end