require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Workstation" do
  
  describe "names" do
    it "should have a name" do
      Workstation.new(:my_workthing).name.should == :my_workthing
    end
    
    it "needs to have a symbol as a name" do
      lambda{Workstation.new("foo")}.should raise_error(ArgumentError)
      lambda{Workstation.new}.should raise_error(ArgumentError)
    end
    
    it "should have a factory_name" do
      Workstation.new(:ws).factory_name.should be_a_kind_of(String)
    end
    
    it "should have a default factory_name of 'factory_name'" do
      Workstation.new(:ws).factory_name.should == 'factory_name'
    end
    
    it "should be possible to set the factory_name via an initialization option" do
      Workstation.new(:ws, factory_name:'foo').factory_name.should == 'foo'
    end
  end
  
  
  describe "database" do
    it "should have a URI for a CouchDB instance" do
      Workstation.new(:ws).couchdb_uri.should be_a_kind_of(String)
    end
    
    it "should default to http://127.0.0.1:5984/\#{@factory_name}" do
      Workstation.new(:ws).couchdb_uri.should == "http://127.0.0.1:5984/factory_name"
    end
  end
  
  
  
  describe "capacity" do
    it "should accept a #capacity attribute in initialization" do
      w1 = Workstation.new(:ws, capacity:12)
      w1.capacity.should == 12
    end
    
    it "should have a default capacity of 100" do
       Workstation.new(:ws).capacity.should == 100
    end
  end
  
  
  describe "downstream_stations" do
    it "should have an Array attribute called #downstream_stations" do
      Workstation.new(:place).downstream_stations.should be_a_kind_of(Array)
    end
    
    it "#downstream_stations should default to an empty Array" do
      Workstation.new(:place).downstream_stations.should == []
    end
  end
  
  
  describe "answers" do
    it "should be an Array that's empty initially" do
      Workstation.new(:place).answers.should == []
    end
  end
  
  
  describe "transfer_answer" do
    before(:each) do
      @a1 = Answer.new("do a", tags:[:here])
      @w1 = Workstation.new(:here)
    end
    
    it "should change the location tag of the Answer by removing self.name and adding destination.name" do
      @w1.transfer_answer(@a1, :there)
      @a1.tags.should include(:there)
      @a1.tags.should_not include(:here)
    end
    
    it "should validate that the new location (tag) is a Symbol" do
      lambda{@w1.transfer_answer(@a1, "garbage")}.should raise_error(ArgumentError)
    end
    
    it "should not change state if the ne location name is invalid" do
      lambda{@w1.transfer_answer(@a1, "garbage")}.should raise_error(ArgumentError)
      @a1.tags.should include(:here)
    end
  end
  
  
  
  
  describe "#cycle" do
    it "should invoke #receive!, #build!, #ship! and #scrap!" do
      w1 = Workstation.new(:place)
      w1.should_receive(:receive!)
      w1.should_receive(:build!)
      w1.should_receive(:ship!)
      w1.should_receive(:scrap!)
      w1.cycle
    end
    
    
    describe "#receive!" do
      it "should access its persistent store"
      
      it "should gather its 'current' work in process into self#answers"
      
      it "should gather its 'current' collaborators' work in process into self#collaborator_answers"
    end
    
    
    describe "#build!" do
      it "should call #generate for each item in self.build_sequence" do
        w1 = Workstation.new(:test)
        w1.build_sequence = [RandomGuessOperator.new]
        w1.build_sequence[0].should_receive(:generate)
        w1.build!
      end
      
    end
    
    
    describe "#ship!" do
      it "should be an Array of stored procedures"
      it "should always include (as a last entry) a Proc that returns 'false'"
      it "should call all the Procs in order, for every member of its population"
      it "should select a random downstream destination if none is specified by the rule"
      it "should fail silently if there are no downstream stations"
      it "should call every rule, in turn, sending every Answer off before moving on"
    end
    
    
    describe "scrap!" do
      it "should be an Array of stored procedures"
      it "should return 'true' to indicate that a particular Answer should be scrapped"
      it "should use an Array of stored procedures"
      it "should return a single boolean to indicate that scrapping should continue"
      it "should always include (as a last entry) a Proc that checks whether population > capacity"
      it "should set the workstation of scrapped Answers to Scrapyard"
      it "should call rules in order, scrapping all indicated Answers, until scrap_trigger? is false"
    end
  end
end