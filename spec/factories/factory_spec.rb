require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "Factory" do
  
  it "should have a name" do
    Factory.new("foo_factory").name.should == "foo_factory"
  end
  
  it "should have a default name of 'my_factory'" do
    Factory.new.name.should == "my_factory"
  end
  
  
  describe "Factory configuration methods" do
    describe "configatron integration" do
      it "should be possible to talk to to #configatron" do
        lambda{configatron.my_thing}.should_not raise_error
      end
    end
    
    
    describe "configure_paths" do
      it "should respond to #configure_paths" do
        Factory.new.should respond_to(:configure_paths!)
      end

      it "should populate self.configatron.factory_root as the path to the project folder" do
        pending "Broken since moving these specs"
        this_spec_file_parent_path = File.expand_path("#{File.dirname(__FILE__)}/..")
        f1 = Factory.new
        f1.configure_paths!
        f1.configatron.factory_root.should == this_spec_file_parent_path
      end
    end


    describe "factory name" do
      it "should populate self.configatron.factory_name" do
        f1 = Factory.new
        f1.configure_constants!
        f1.configatron.factory_name.should == "my_factory"

        f1 = Factory.new("super_fancy")
        f1.configure_constants!
        f1.configatron.factory_name.should == "super_fancy"
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
        f1 = Factory.new("boo")
        lambda{f1.couch_available?}.should_not raise_error
      end
      
      it "should return true if the uri is reachable" do
        uri = "http://mycouch.db/boo"
        f1 = Factory.new("boo")
        f1.configatron.couchdb_uri = uri
        FakeWeb.register_uri(:any, uri, :body => "We are here!", :status => [200, "OK"])
        f1.couch_available?.should == true
      end
      
      it "should return false if the uri is offline or 404's out" do
        uri = "http://mycouch.db/boo"
        f1 = Factory.new("boo")
        f1.configatron.couchdb_uri = uri
        f1.configatron.couchdb_uri.should == uri
        FakeWeb.register_uri(:any, uri, :body => "Go away!", :status => [404, "Not Found"])
        f1.couch_available?.should == false
        
        f1 = Factory.new("boo") # depends on this being wrong
        f1.configatron.couchdb_uri = "http://127.0.0.1:9991/place"
        f1.couch_available?.should == false
      end
    end
  end
  
  
  describe "build_from_config" do
    it "should read the config files"
    
    it "should #reset"
  end
  
  
  describe "reset_from_config" do
    it "should erase the couchdb"
    
    it "should set up a new couchdb"
    
    it "should set up the necessary design documents in the db"
  end
  
  
  describe "activate" do
    it "should check the config files"
  end
  
  
  describe "ontology" do
    it "should have a master Instruction list" do
      Factory.new("foo").instruction_library.should == Instruction.all_instructions
    end
    
    it "should be possible to override the default with an option" do
      short_list = [IntAddInstruction, CodeNoopInstruction]
      Factory.new("foo", instruction_library:short_list).instruction_library.should ==
        short_list
    end
    
    it "should have a master NudgeType list" do
      Factory.new("foo").type_library.should == NudgeType.all_types
    end
    
    it "should be possible to override the default with an option" do
      short_list = [CodeType, BoolType]
      Factory.new("foo", type_library:short_list).type_library.should ==
        short_list
    end
    
    it "should save all the Hash options it was called with" do
      Factory.new("bar", my_option:1, my_other_option:[1,2,3]).original_options_hash.should ==
        {:my_option=>1, :my_other_option=>[1, 2, 3]}
    end
    
  end
  
  describe "workstations" do
    it "should have a list of extant workstations"
    
  end
  
  
end