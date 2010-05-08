require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machine infrastructure" do
  describe "initialize method" do
    it "should accept an options hash, and save that as an attribute" do
      Machines::Machine.new(ghosts:["red", "blue"]).options[:ghosts].should include("blue")
      Machines::Machine.new(voyages:7).options[:voyages].should == 7
    end
  end
end