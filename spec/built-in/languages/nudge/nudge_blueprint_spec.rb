# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../spec_helper'

describe NudgeBlueprint do
  it "langauge name is :Nudge" do
    blueprint = NudgeBlueprint.new
    blueprint.language.should == :Nudge
  end
  
  describe "deleting points at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
    end
    
    it "returns a new blueprint" do
      Random.should_receive(:rand).with(3).and_return(2)
      @blueprint.delete_n_points_at_random(1).should be_kind_of(NudgeBlueprint)
    end
    
    it "removes a random point from the program once when called with 1" do
      Random.should_receive(:rand).with(3).and_return(2)
      @blueprint.delete_n_points_at_random(1).should == "block { ref x value «code» }\n«code»value «int»\n«int»1" 
    end
    
    it "removes a random point from the program n-times when when called with n" do
      Random.should_receive(:rand).with(3).ordered.and_return(2)
      Random.should_receive(:rand).with(2).ordered.and_return(1)
      
      @blueprint.delete_n_points_at_random(2).should == "block { ref x }\n" 
    end
    
    it "raises NudgeError::PointIndexTooLarge if called with n higher than number of points" do      
      lambda { @blueprint.delete_n_points_at_random(12)}.should raise_error(NudgeError::PointIndexTooLarge)
    end
  end
  
  describe "inserting points at random" do
    before(:each) do
      code = "block { ref x value «code» do int_add }\n«int»1\n«code»value «int»\n«int»2"
      @blueprint = NudgeBlueprint.new(code)
      @writer = NudgeWriter.new
    end
    
    it "returns a new blueprint" do
      pending
      @blueprint.insert_n_points_at_random(1, @writer).should be_kind_of(NudgeBlueprint)
    end
    
    it "inserts a random point from the program once when called with 1" do
      pending
    end
    
    it "inserts a random point from the program n-times when called with n" do
      pending
    end
  end
end