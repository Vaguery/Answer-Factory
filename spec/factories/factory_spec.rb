require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "Factory" do
  describe "Factory configuration methods" do
    describe "defaults, via configatron" do
      it "should be possible to talk to to #configatron from here" do
        lambda{configatron.my_thing}.should_not raise_error
      end
      
      describe "Factory.new should have reasonable default values" do
        it "should use 'my_factory' for #name" do
          f1 = Factory.new
          f1.name.should == "my_factory"
        end
        
        it "should use an empty Array for #workstation_names" do
          f1 = Factory.new
          f1.workstation_names.should == []
        end
        
        it "should use 'http://127.0.0.1:5984' for #couchdb_server" do
          f1 = Factory.new
          f1.couchdb_server.should == 'http://127.0.0.1:5984'
        end
        
        it "should use Nudge::Instruction.all_instructions for #nudge_instructions" do
          f1 = Factory.new
          f1.nudge_instructions.should == Instruction.all_instructions
        end
        
        it "should use Nudge::NudgeType.all_types for #nudge_types" do
          f1 = Factory.new
          f1.nudge_types.should == NudgeType.all_types
        end
      end
      
      
      describe "Factory.new should hit configatron for default values" do
        it "should hit configatron for #name" do
          configatron.temp do
            configatron.factory.name = "foo"
            f1 = Factory.new
            f1.name.should == "foo"
          end
        end
        
        it "should hit configatron for #nudge_instructions" do
          configatron.temp do
            configatron.nudge.instructions.all = [IntSubtractInstruction]
            f1 = Factory.new
            f1.nudge_instructions.should == [IntSubtractInstruction]
          end
        end
        
        it "should hit configatron for #nudge_types" do
          configatron.temp do
            configatron.nudge.types.all = [BoolType]
            f1 = Factory.new
            f1.nudge_types.should == [BoolType]
          end
        end
        
        it "should hit configatron for #workstation_names" do
          configatron.temp do
            configatron.factory.workstation_names = [:bar, :baz]
            f1 = Factory.new
            f1.workstation_names.should == [:bar, :baz]
          end
        end
        
        it "should hit configatron for #couchdb_server" do
          configatron.temp do
            configatron.factory.couchdb.server = "http://my.otherplace.com:7771"
            f1 = Factory.new
            f1.couchdb_server.should == "http://my.otherplace.com:7771"
          end
        end
        
      end
      
      
      describe "writing overridden defaults to configatron" do
        describe "Factory.new should overwrite configatron default values" do
          it "should overwrite #factory_name" do
            Factory.new(name:"golly")
            configatron.factory.name.should == "golly"
          end
          
          it "should overwrite #nudge.instructions.all" do
            Factory.new(nudge_instructions:[BoolAndInstruction])
            configatron.nudge.instructions.all.should == [BoolAndInstruction]
          end
          
          it "should overwrite #nudge.types.all" do
            Factory.new(nudge_types:[BoolType])
            configatron.nudge.types.all.should == [BoolType]
          end
          
          it "should overwrite #factory.workstation_names" do
            Factory.new(workstation_names:[:xenon])
            configatron.factory.workstation_names.should == [:xenon]
          end
          
          it "should overwrite #factory.couchdb.server" do
            Factory.new(couchdb_server:"http://127.0.0.1:9999")
            configatron.factory.couchdb.server.should == "http://127.0.0.1:9999"
          end
        end
      end
      
    end

    describe "database setup" do
      describe "paths" do
        it "should have reasonable defaults"
        
        describe "setting from file" do
          it "should populate configatron.main_database.db_root"
          
          it "should populate configatron.main_database.db_name"
        end
      end
    end
    
    
    describe "Nudge Language setup" do
      it "should have reasonable defaults"
      
      describe "setting from file" do
        it "should replace configatron.ontology.nudge.types"
        it "should replace configatron.ontology.nudge.instructions"
      end
    end
    
    
    describe "Workstation setup" do
      it "should have reasonable defaults"
      
      describe "setting from file" do
        it "should replace configatron.workstations"
        it "should replace 'configatron.[workstation_name].[settings]' for each workstation"
      end
    end
  end
  
  
  describe "databases" do
    describe "#couch_available?" do
      it "should have a method to check that couchDB is accessible" do
        f1 = Factory.new(name:"boo")
        lambda{f1.couch_available?}.should_not raise_error
      end
      
      it "should return true if the uri is reachable" do
        uri = "http://mycouch.db/boo"
        f1 = Factory.new(name:"boo")
        f1.configatron.couchdb_uri = uri
        FakeWeb.register_uri(:any, uri, :body => "We are here!", :status => [200, "OK"])
        f1.couch_available?.should == true
      end
      
      it "should return false if the uri is offline or 404's out" do
        uri = "http://mycouch.db/boo"
        f1 = Factory.new(name:"boo")
        f1.configatron.couchdb_uri = uri
        f1.configatron.couchdb_uri.should == uri
        FakeWeb.register_uri(:any, uri, :body => "Go away!", :status => [404, "Not Found"])
        f1.couch_available?.should == false
        
        f1 = Factory.new(name:"boo") # depends on this being wrong
        f1.configatron.couchdb_uri = "http://127.0.0.1:9991/place"
        f1.couch_available?.should == false
      end
    end
  end
  
  
  
  
end