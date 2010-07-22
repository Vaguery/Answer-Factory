# encoding: UTF-8
require File.expand_path("../../answer_factory", File.dirname(__FILE__))

describe "Score" do
  describe ".load (id: Integer, value: Float)" do
    it "sets @id to id.to_i" do
      score = Score.load(1, 1.5)
      score.instance_variable_get(:@id).should == 1
    end
    
    it "sets @value to value.to_f" do
      score = Score.load(1, 1.5)
      score.instance_variable_get(:@value).should == 1.5
    end
  end
  
  describe ".new (value: Float)" do
    it "sets @value to value.to_f" do
      score = Score.new(1.5)
      score.instance_variable_get(:@value).should == 1.5
    end
  end
  
  describe "#id" do
    it "returns @id" do
      score = Score.load(1, 1.5)
      score.id.should == 1
    end
  end
  
  describe "#value" do
    it "returns @value" do
      score = Score.new(1.5)
      score.value.should == 1.5
    end
  end
end
