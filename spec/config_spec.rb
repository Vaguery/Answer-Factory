require File.join(File.dirname(__FILE__), "./spec_helper")


describe "Factory configuration methods" do
  describe "configatron integration" do
    it "should respond to #configatron" do
      Factory.new.should respond_to(:configatron)
    end
  end
  
  
  describe "configure_paths" do
    it "should respond to #configure_paths" do
      Factory.new.should respond_to(:configure_paths!)
    end
    
    it "should populate self.configatron.factory_root as the path to the project folder" do
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
      it "should read from database.yml" do
        f1 = Factory.new("super_fancy")
        f1.configatron.should_receive(:configure_from_yaml)
        f1.configure!
      end
      
      describe "subject" do
        before(:each) do
          @f1 = Factory.new()
          @f1.configure!
        end
        
        it "should populate configatron.main_database.db_root" do
          @f1.configatron.main_database.db_root.should == "http://127.0.0.1:5984"
        end
        
        it "should populate configatron.main_database.db_name" do
          @f1.configatron.main_database.db_name.should == "my_factory" # from the config file
        end

        it "should populate configatron.main_database.tag_filter" do
          @f1.configatron.main_database.tag_filter.should == "_design/routing/_view/by_tag"
        end
      end
      
    end

    describe "checking for CouchDB access" do
      it "should call Factory#couch_db?"
    end

    describe "setting up initial db" do
      it "should not remove old records unless asked to do so"
      it "should be possible to erase the db if a flag is set"
      it "should set up the design document"
      it "should write the search-by-tag filter view to the design document"
    end
  end


  describe "Nudge language setup" do
    it "should set up the Instructions"

    it "should set up the Types"

  end
  
end






