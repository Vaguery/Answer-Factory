require 'answer_factory'

describe "Answer" do
  describe ".load (id: Integer, blueprint: String, language: String, progress: Integer)" do
    it "sets @id to id.to_i" do
      answer = Answer.load(1, "ref x", "nudge", 5)
      answer.instance_variable_get(:@id).should == 1
    end
    
    it "sets @blueprint to blueprint.to_s" do
      answer = Answer.load(1, "ref x", "nudge", 5)
      answer.instance_variable_get(:@blueprint).should == "ref x"
    end
    
    it "sets @language to language.to_s" do
      answer = Answer.load(1, "ref x", "nudge", 5)
      answer.instance_variable_get(:@language).should == "nudge"
    end
    
    it "sets @progress to progress.to_i" do
      answer = Answer.load(1, "ref x", "nudge", 5)
      answer.instance_variable_get(:@progress).should == 5
    end
    
    it "sets @scores to {}" do
      answer = Answer.load(1, "ref x", "nudge", 5)
      answer.instance_variable_get(:@scores).should == {}
    end
  end
  
  describe ".new (blueprint: String, language: String)" do
    it "sets @blueprint to blueprint.to_s" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_get(:@blueprint).should == "ref x"
    end
    
    it "sets @language to language.to_s" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_get(:@language).should == "nudge"
    end
    
    it "sets @progress to 0" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_get(:@progress).should == 0
    end
    
    it "sets @scores to {}" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_get(:@scores).should == {}
    end
  end
  
  describe "#id" do
    it "returns @id" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_set(:@id, 1)
      
      answer.id.should == 1
    end
  end
  
  describe "#blueprint" do
    it "returns @blueprint" do
      answer = Answer.new("ref x", "nudge")
      answer.blueprint.should == "ref x"
    end
  end
  
  describe "#workstation" do
    it "returns @workstation" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_set(:@workstation, :w)
      
      answer.workstation.should == :w
    end
  end
  
  describe "#machine" do
    it "returns @machine" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_set(:@machine, :m)
      
      answer.machine.should == :m
    end
  end
  
  describe "#language" do
    it "returns @language" do
      answer = Answer.new("ref x", "nudge")
      answer.language.should == "nudge"
    end
  end
  
  describe "#progress" do
    it "returns @progress" do
      answer = Answer.new("ref x", "nudge")
      answer.progress.should == 0
    end
  end
  
  describe "#assign (workstation_name: Symbol, machine_name: Symbol or nil)" do
    it "sets @workstation to workstation_name" do
      answer = Answer.new("ref x", "nudge")
      answer.assign(:w, :m)
      
      answer.instance_variable_get(:@workstation).should == :w
    end
    
    it "sets @machine to machine_name" do
      answer = Answer.new("ref x", "nudge")
      answer.assign(:w, :m)
      
      answer.instance_variable_get(:@machine).should == :m
    end
  end
  
  describe "#score (score_name: Symbol)" do
    it "returns Factory::Infinity when no score exists with the given name" do
      Factory::Infinity = 1e300
      answer = Answer.new("ref x", "nudge")
      
      answer.score(:foo).should == Factory::Infinity
    end
    
    it "returns the float representing the score value associated with the given name" do
      answer = Answer.new("ref x", "nudge")
      answer.instance_variable_set(:@scores, {:pi => Score.new(3.14)})
      
      answer.score(:pi).should == 3.14
    end
  end
  
  describe "#score (score_hash: Hash)" do
    it "creates a score with the hash key as its name" do
      answer = Answer.new("ref x", "nudge")
      score = Score.new(1.5)
      
      Score.stub!(:new).and_return(score)
      
      answer.score(:length => 1.5)
      
      answer.instance_variable_get(:@scores).should == {:length => score}
    end
    
    it "sets a new value for an existing score" do
      answer = Answer.new("ref x", "nudge")
      
      answer.score(:length => 1.5)
      score = answer.instance_variable_get(:@scores)[:length]
      score.instance_variable_get(:@value).should == 1.5
      
      answer.score(:length => 2.5)
      score.instance_variable_get(:@value).should == 2.5
    end
  end
end
