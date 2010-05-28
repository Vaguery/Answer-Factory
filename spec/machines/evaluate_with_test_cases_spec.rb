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
  
  before(:each) do
    @canned = '{"total_rows":1,"offset":0,"rows":[{"id":"0f60c293ad736abfdb083d33f71ef9ab","key":"ws1","value":{"_id":"0f60c293ad736abfdb083d33f71ef9ab","_rev":"1-473467b6dc1a4cba3498dd6eeb8e3206","blueprint":"do bar","tags":[],"scores":{},"progress":12,"timestamp":"2010/04/14 17:09:14 +0000"}}]}'
    
    FakeWeb.register_uri(:any, "http://127.0.0.1:5984/foo_training/_design/tester/_view/test_cases",
      :body => @canned, :status => [200, "OK"])
    @factory = Factory.new(name:"foo")
    @tester = EvaluateWithTestCases.new(name: :tester)
  end
  
  describe "initialization" do
    
    describe "machine name" do
      it "should have a name" do
        @tester.should respond_to(:name)
      end
    end
    
    describe "data" do
      it "should call #load_training_data! if" do
        EvaluateWithTestCases.new(name: :tester)
      end
    end
    
    describe "sensors" do
      it "should have a #sensors attribute" do
        EvaluateWithTestCases.new(name: :tester).should respond_to(:sensors)
      end

      it "should default to an empty Hash" do
        EvaluateWithTestCases.new(name: :tester).sensors.should == {}
      end
      
      describe ":build_sensor" do
        before(:each) do
          @m1 = EvaluateWithTestCases.new(name: :tester)
        end
        
        it "should respond to :build_sensor" do
          @m1.should respond_to(:build_sensor)
        end
        
        it "should use the name argument as the Hash key in #sensors" do
          @m1.build_sensor("harbor_master_score")
          @m1.sensors.keys.should include("harbor_master_score")
        end
        
        it "should take a block and store it as a Proc as the value in #sensors" do
          block = lambda {|a| 9}
          @m1.build_sensor("harbor_master_score", &block)
          @m1.sensors["harbor_master_score"].should == block
        end
      end
      
    end
  end
  
  
  describe "#score method" do
    it "should respond to :score" do
      @tester.should respond_to(:score)
    end
    
    it "should only accept a Batch" do
      lambda{@tester.score(99)}.should raise_error(ArgumentError)
      lambda{@tester.score(Batch.new)}.should_not raise_error(ArgumentError)
    end
    
    describe "running Interpreter" do
      before(:each) do
        @tester.test_cases = [TestCase.new(inputs: {"x1:int" => 1}, outputs: {"y1" => 2})]
        @batch = Batch.[](Answer.new("do a"))
      end
      
      it "should create one Interpreter for each TestCase of #data_in_hand" do
        i = Interpreter.new("")
        Interpreter.should_receive(:new).at_least(1).times.and_return(i)
        @tester.score(@batch)
      end
      
      it "should register all the sensors" do
        @tester.sensors = {"y1" => Proc.new{|interpreter| interpreter.peek_value(:int)} }
        i = Interpreter.new
        Interpreter.stub(:new).and_return(i)
        i.should_receive(:register_sensor).exactly(1).times
        @tester.score(@batch)
      end

      it "should set up Interpreters correctly" do
        i = Interpreter.new
        Interpreter.should_receive(:new).with(
          "do a", {:name=>:tester, :target_size_in_points=>99}).and_return(i)
        @tester.score(@batch,target_size_in_points:99)
      end
    end
    
    
    describe "install_training_data_from_csv!" do
      before(:each) do
        FakeWeb.register_uri(:any,
          "http://127.0.0.1:5984/dammit_training/_bulk_docs", 
          :body => @canned, :status => [200, "OK"])
        FakeWeb.register_uri(:any,
          "http://127.0.0.1:5984/dammit_training/_design/tester/_view/test_cases", 
          :body => @canned, :status => [200, "OK"])
        
        
        
        @f1 = Factory.new(name: "dammit")
        @my_csv = "./spec/fixtures/my_data_source.csv"
        @m1 = EvaluateWithTestCases.new(name: :tester, training_data_csv: @my_csv)
        @training_db = "http://127.0.0.1:5984/dammit_training"
        @my_view = {'_id' => "_design/tester",
            views: { test_cases: { map: 
              "function(doc) { emit(doc._id, doc); }"}}}
        
      end
      
      it "should get the filename as an initialization parameter" do
        EvaluateWithTestCases.new(name: :tester, training_data_csv: "foo.csv").
          csv_filename.should == "foo.csv"
        EvaluateWithTestCases.new(name: :tester).csv_filename.should == nil
      end
      
      it "should open a csv file" do
        @m1.stub(:save_view_doc!)   # we're just checking the file is touched
        f = File.open(@my_csv)
        File.stub(:open).and_return(f)
        c = CSV.new(f, headers: true)
        CSV.stub(:new).with(f, headers: true).and_return(c)
        @m1.install_training_data_from_csv(@my_csv)
      end
      
      it "should be the training_data default db" do
        @m1.stub(:save_view_doc!)   # we're just checking the filename
        db = CouchRest.database!(@training_db)
        CouchRest.stub(:database!).with(@training_db).and_return(db)
        @m1.install_training_data_from_csv(@my_csv)
      end
      
      it "makes one doc for every row" do
        @m1.stub(:save_view_doc!)   # we're just checking data row saving
        db = CouchRest.database!(@training_db)
        CouchRest.stub(:database!).with(@training_db).and_return(db)
        db.should_receive(:bulk_save_doc).exactly(3).times
        @m1.install_training_data_from_csv(@my_csv)
      end
      
      
      it "should raise an error if every header doesn't contain a colon and a type string" do
        lambda{@m1.header_prep("x1")}.should raise_error ArgumentError
        lambda{@m1.header_prep("x1:")}.should raise_error ArgumentError
        lambda{@m1.header_prep("x1:int")}.should_not raise_error ArgumentError
        lambda{@m1.header_prep(":int")}.should raise_error ArgumentError
      end
      
      it "should create the appropriate view document" do
        db = CouchRest.database!(@training_db)
        CouchRest.stub(:database!).with(@training_db).and_return(db)
        db.stub(:bulk_save_doc)
        db.should_receive(:save_doc).exactly(1).times.with(@my_view)
        @m1.install_training_data_from_csv(@my_csv)
      end
      
    end
    
    
    
    describe "load_training_data!" do
      
      before(:each) do
        @factoreee = Factory.new(name:"dammit")
        @m1 = EvaluateWithTestCases.new(name: :tester)
        @design_doc = "tester/test_cases"  # we'll assume this has been set up!
        @expected = {"total_rows"=>1, "offset"=>0, "rows"=>[{"id"=>"05d195b7bb436743ee36b4223008c4ce", "key"=>"05d195b7bb436743ee36b4223008c4ce", "value"=>{"_id"=>"05d195b7bb436743ee36b4223008c4ce", "_rev"=>"1-c9fae927001a1d4789d6396bcf0cd5a7", "inputs"=>{"x1:int"=>7}, "outputs"=>{"y1:grault"=>12}}}]}
        
      end
      
      it "should get the couch_db uri from configatron" do
        @m1.training_data_view.should ==
          "http://127.0.0.1:5984/dammit_training/_design/#{@m1.name}/_view/test_cases"
      end
      
      it "should respond to :load_training_data!" do
        @m1.should respond_to(:load_training_data!)
      end
      
      it "should access the couch_db uri" do
        FakeWeb.register_uri(:any,
          "http://127.0.0.1:5984/dammit_training/_design/tester/_view/test_cases", 
          :body => @canned, :status => [200, "OK"])
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.stub(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        @m1.load_training_data!
      end
      
      it "should throw a useful error if the view isn't available"
      
      it "should ask for the view document" do
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.stub(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        @m1.load_training_data!
      end
      
      it "should store Array of TestCases in @test_cases" do
        db = CouchRest.database!(@m1.training_datasource)
        CouchRest.stub(:database!).and_return(db)
        db.should_receive(:view).with(@design_doc).and_return(@expected)
        
        @m1.load_training_data!
        @m1.test_cases.should be_a_kind_of(Array)
        @m1.test_cases.length.should == 1
      end
    end
    
    
    describe "scoring" do
      before(:each) do
        @m1 = EvaluateWithTestCases.new(name: :tester)
        @m1.test_cases = (0...10).collect do |i|
          TestCase.new(inputs: {"x1:int" => i}, outputs: {"y1" => 2*i, "y2" => 3*i})
        end
        @m1.build_sensor("y1") {|a| 777}
        @m1.build_sensor("y2") {|a| 666}
        
        @batch = Batch.[](Answer.new("do a"))
        @i1 = Interpreter.new
      end
      
      it "should make an Interpreter for each row of training data" do
        @m1.stub!(:load_training_data!)
        Interpreter.should_receive(:new).exactly(10).times.and_return(@i1)
        @m1.score(@batch)
      end
      
      it "should run all the Interpreters" do
        @m1.stub!(:load_training_data!)
        Interpreter.stub(:new).exactly(10).times.and_return(@i1)
        @i1.should_receive(:run).at_least(1).times.and_return({})
        @m1.score(@batch)
      end
      
      it "should register its sensors before each Interpreter run" do
        Interpreter.stub(:new).and_return(@i1)
        @i1.should_receive(:register_sensor).at_least(1).times
        @m1.score(@batch)
      end
      
      it "should have a score for each sensor" do
        @m1.score(@batch)
        @batch.first.scores[:tester_y1].should_not == nil
        @batch.first.scores[:tester_y2].should_not == nil
      end
      
      it "should not re-evaluate an Answer's score if :static is true and the score is set" do
        pending
        @m1.score(@batch)
        Interpreter.should_not_receive(:new)
        @m1.score(@batch, static:true)
      end
      
      it "should return sum of absolute errors" do
        @m1.stub!(:load_training_data!)
        @m1.score(@batch)
        @batch[0].scores[:tester_y1].should == 777+775+773+771+769+767+765+763+761+759
        @batch[0].scores[:tester_y2].should == 666+663+660+657+654+651+648+645+642+639
      end
    end
    
    
  end
end