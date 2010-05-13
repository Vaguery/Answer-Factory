require File.join(File.dirname(__FILE__), "./../spec_helper")
include Machines

FakeWeb.allow_net_connect = false


describe "Machines::TestCase" do
  describe "inputs Array" do
    before(:each) do
      @tc = TestCase.new
    end
    
    describe "bindings" do
      it "should have an attribute called #inputs" do
        @tc.should respond_to(:inputs)
      end
      
      it "should accept a Hash as an initialization argument for #inputs" do
        lambda{TestCase.new(inputs:{})}.should_not raise_error
        TestCase.new(inputs:{"x1" => [:int, 12]}).inputs.should ==
          {"x1" => [:int, 12]}
      end
      
      it "should default :inputs to an empty Hash" do
        TestCase.new.inputs.should == {}
      end
      
      it "should have an attribute called #outputs" do
        @tc.should respond_to(:outputs)
      end
      
      it "should accept a Hash as an initialization argument for #outputs" do
        lambda{TestCase.new(outputs:{})}.should_not raise_error
        TestCase.new(outputs:{"y1" => [:bool, false]}).outputs.should ==
          {"y1" => [:bool, false]}
      end
      
      it "should default :inputs to an empty Hash" do
        TestCase.new.outputs.should == {}
      end
    end
  end
end


describe "EvaluateWithTestCases" do
  
  describe "initialization" do
    before(:each) do
      @evt = EvaluateWithTestCases.new
    end
    
    describe "name" do
      it "should have a name" do
        @evt.should respond_to(:name)
      end
    end
    
    describe "data_in_hand" do
      it "should have a #data_in_hand attribute" do
        EvaluateWithTestCases.new.should respond_to(:data_in_hand)
      end

      it "should default to an empty Hash" do
        EvaluateWithTestCases.new.data_in_hand.should == {}
      end
    end
    
    describe "sensors" do
      it "should have a #sensors attribute" do
        EvaluateWithTestCases.new.should respond_to(:sensors)
      end

      it "should default to an empty Hash" do
        EvaluateWithTestCases.new.sensors.should == {}
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
      @tester = EvaluateWithTestCases.new(name: :tester)
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
    
    describe "running Interpreter" do
      before(:each) do
        @tester.data_in_hand = [TestCase.new( {"x1" => [:int, 8], "y1" => [:int, 7]} )]
        @batch = Batch.[](Answer.new("do a"))
      end
      
      it "should create one Interpreter for each TestCase of #data_in_hand" do
        i = Interpreter.new
        Interpreter.should_receive(:new).and_return(i)
        @tester.score(@batch)
      end
      
      it "should register all the sensors" do
        @tester.sensors = {"y1" => Proc.new{|interpreter| interpreter.peek_value(:int)} }
        i = Interpreter.new
        Interpreter.should_receive(:new).and_return(i)
        i.should_receive(:register_sensor).exactly(1).times
        @tester.score(@batch)
      end

      it "should set up Interpreters correctly" do
        i = Interpreter.new
        Interpreter.should_receive(:new).with(
          "ref x1", {:name=>:tester, :target_size_in_points=>99}).and_return(i)
        @tester.score(@batch,target_size_in_points:99)
      end
      
    end
    
    
    it "should accept an Array of TestCases"
    
    
    describe "load_training_data!" do
      
      before(:each) do
        @factoreee = Factory.new(name:"grault")
        @m1 = EvaluateWithTestCases.new()
        @design_doc = "evaluator/test_cases"  # we'll assume this has been set up!
        @expected = {"total_rows"=>1, "offset"=>0, "rows"=>[{"id"=>"05d195b7bb436743ee36b4223008c4ce", "key"=>"05d195b7bb436743ee36b4223008c4ce", "value"=>{"_id"=>"05d195b7bb436743ee36b4223008c4ce", "_rev"=>"1-c9fae927001a1d4789d6396bcf0cd5a7", "inputs"=>{"x1"=>7}, "outputs"=>{"y1"=>12}}}]}
        
      end
      
      it "should get the couch_db uri from configatron" do
        @m1.training_data_view.should ==
          "http://127.0.0.1:5984/grault_training/_design/#{@m1.name}/_view/test_cases"
      end
      
      it "should respond to :load_training_data!" do
        @m1.should respond_to(:load_training_data!)
      end
      
      it "should access the couch_db uri" do
        FakeWeb.register_uri(:any,
          "http://127.0.0.1:5984/grault_training/_design/evaluator/_view/test_cases", 
          :body => "{}", :status => [200, "OK"])
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.should_receive(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        @m1.load_training_data!
      end
      
      it "should throw a useful error if the view isn't available"
      
      it "should ask for the view document" do
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.should_receive(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        @m1.load_training_data!
      end
      
      it "should store Array of TestCases in @test_cases" do
        
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.should_receive(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        
        @m1.load_training_data!
        @m1.test_cases.should be_a_kind_of(Array)
        @m1.test_cases.length.should == 1
      end
      
      
      it "does something"
      
    end
      
      
      
    
    
    
    it "should run the :error_measure Proc on all expected/observed pairs"
    
    it "should run the :aggregator Proc on all the error_measure results"
    
    it "should write the aggregated score to the Answer's :scores Hash"
    
  end
end