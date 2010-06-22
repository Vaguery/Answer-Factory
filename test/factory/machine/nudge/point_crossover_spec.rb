require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper)
Workstation.new(:w)

describe "Machine::Nudge::PointCrossover" do
  describe "#defaults" do
    it "sets path :of_children to self" do
      m = Machine::Nudge::PointCrossover.new(:m, :w)
      m.defaults
      m.path[:of_children].should == m
    end
    
    it "sets path :of_parents to self" do
      m = Machine::Nudge::PointCrossover.new(:m, :w)
      m.defaults
      m.path[:of_parents].should == m
    end
    
    it "sets path :of_unused to self" do
      m = Machine::Nudge::PointCrossover.new(:m, :w)
      m.defaults
      m.path[:of_unused].should == m
    end
  end
  
  describe "#process (answers)" do
    it "if answers.length == 1, sends that answer unchanged down path :of_unused and exits immediately" do
      m = Machine::Nudge::PointCrossover.new(:m, :w)
      b = "block { ref x ref y }"
      a = Answer.new(:blueprint => b)
      
      m.should_receive(:send_answers).with([a], m.path[:of_unused])
      
      m.process([a])
    end
    
    it "removes two answers from the array and sends the rest down path :of_unused" do
      pending
      m = Machine::Nudge::PointCrossover.new(:m, :w)
      
      ab = Answer.new(:blueprint => "block { ref a ref b }")
      cd = Answer.new(:blueprint => "block { ref c ref d }")
      ef = Answer.new(:blueprint => "block { ref e ref f }")
      gh = Answer.new(:blueprint => "block { ref g ref h }")
      
      answers = [ab, cd, ef, gh]
      
      answers.stub!(:shuffle!).and_return(answers)
      
      m.should_receive(:send_answers).with(answers, m.path[:of_unused])
      
      m.process(answers)
    end
  end
end
