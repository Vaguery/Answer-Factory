require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::TestCase" do
  describe "inputs Array" do
    before(:each) do
      @tc = Machines::TestCase.new
    end
    
    describe "bindings" do
      it "should have an attribute called #inputs" do
        @tc.should respond_to(:inputs)
      end
      
      it "should accept a Hash as an initialization argument for #inputs" do
        lambda{Machines::TestCase.new(inputs:{})}.should_not raise_error
        Machines::TestCase.new(inputs:{"x1" => [:int, 12]}).inputs.should ==
          {"x1" => [:int, 12]}
      end
      
      it "should default :inputs to an empty Hash" do
        Machines::TestCase.new.inputs.should == {}
      end
      
      it "should have an attribute called #outputs" do
        @tc.should respond_to(:outputs)
      end
      
      it "should accept a Hash as an initialization argument for #outputs" do
        lambda{Machines::TestCase.new(outputs:{})}.should_not raise_error
        Machines::TestCase.new(outputs:{"y1" => [:bool, false]}).outputs.should ==
          {"y1" => [:bool, false]}
      end
      
      it "should default :inputs to an empty Hash" do
        Machines::TestCase.new.outputs.should == {}
      end
    end
  end
end


describe "Machines::EvaluateWithTestCases" do
  
  describe "initialization" do
    describe "name" do
      it "should have a name"
      
      it "must have a name"
    end
    
    describe "dataset" do
      it "should have a #dataset attribute" do
        Machines::EvaluateWithTestCases.new.should respond_to(:dataset)
      end

      it "should default to an empty Hash" do
        Machines::EvaluateWithTestCases.new.dataset.should == {}
      end
    end
    
    describe "sensors" do
      it "should have a #sensors attribute" do
        Machines::EvaluateWithTestCases.new.should respond_to(:sensors)
      end

      it "should default to an empty Hash" do
        Machines::EvaluateWithTestCases.new.sensors.should == {}
      end
      
      it "should raise an error if the length of #sensors is different from the length of #outputs"
    end
    
    describe "datasource" do
      
      it "should have a :data_source"
      
      it "should have a :data_adapter"
      
    end
    
    describe "error aggregation" do
      it "should have an :error_measure Proc"
      
      it "should have an :aggregator Proc"
    end
  end
  
  
  describe "#score method" do
    before(:each) do
      @tester = Machines::EvaluateWithTestCases.new(name: :quizzer)
    end
    
    it "should respond to :score" do
      @tester.should respond_to(:score)
    end
    
    it "should only accept a Batch" do
      lambda{@tester.score(99)}.should raise_error(ArgumentError)
      lambda{@tester.score(Batch.new)}.should_not raise_error(ArgumentError)
    end
    
    it "should be able to sample randomly from the :datasource"
    
    it "should be able to do vertical_slicing of the :datasource"
    
    it "should be able to train exhaustively from the :datasource"
    
    it "should create Interpreters"
    
    it "should set up Interpreters correctly"
    
    it "should accept an Array of TestCases"
    
    it "should be able to access the :datasource directly to draw next TestCases"
    
    it "should run the :error_measure Proc on all expected/observed pairs"
    
    it "should run the :aggregator Proc on all the error_measure results"
    
    it "should write the aggregated score to the Answer's :scores Hash"
    
  end
end