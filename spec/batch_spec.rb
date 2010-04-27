require File.join(File.dirname(__FILE__), "./spec_helper")

describe "Batches" do
  it "should be a kind of Array" do
    Batch.new.should be_a_kind_of(Array)
  end
  
  it "should raise an exception if a non-Answer is added after initialization" do
    careful = Batch.[](Answer.new("block {}"), Answer.new("block {}"))
    careful.length.should == 2
    
    lambda{careful = Batch.[](12)}.should raise_error(ArgumentError)
    lambda{careful = Batch.[](Answer.new("do int_add"))}.should_not raise_error(ArgumentError)
    
    lambda{careful = Batch.[](Answer.new("do int_add"),12)}.should raise_error(ArgumentError)
    lambda{careful = Batch.[](Answer.new("do int_add"),
      Answer.new("do int_add"))}.should_not raise_error(ArgumentError)
      
    lambda{careful = Batch.new(12)}.should raise_error(ArgumentError)
    lambda{careful = Batch.new(Answer.new("do int_add"))}.should_not raise_error(ArgumentError)
    
    lambda{careful[1] = 991}.should raise_error(ArgumentError)
    lambda{careful[1] = Answer.new("do int_add")}.should_not raise_error(ArgumentError)
    
    lambda{careful << false}.should raise_error(ArgumentError)
    lambda{careful << Answer.new("do int_add")}.should_not raise_error(ArgumentError)
  end
  
  
  describe "database persistence" do
    before(:each) do
      FakeWeb.allow_net_connect = false
    end
    
    describe "bulk_save!" do
      it "should have a #bulk_save method" do
        Batch.new.should respond_to(:bulk_save!)
      end
      
      it "should validate a String as its argument" do
        lambda{Batch.new.bulk_save!("some string")}.should_not raise_error(ArgumentError)
        lambda{Batch.new.bulk_save!(8812)}.should raise_error(ArgumentError)
      end
      
      
      describe "writing" do
        before(:each) do
          @uri = "http://mycouch.db/boo"
          @b1 = Batch.new
          @a1 = Answer.new("do a")
          @b1 << @a1
        end
        
        it "should create the database if it doesn't exist" do
          FakeWeb.register_uri(:any, @uri, :body => "We are here!", :status => [200, "OK"])
          CouchRest.stub(:database!).and_return(the_db = Object.new)
          the_db.stub!(:bulk_save)
          CouchRest.should_receive(:database!)
          Batch.new.bulk_save!(@uri)
        end

        it "should bulk_save the Answers" do
          CouchRest.stub(:database!).and_return(the_db = Object.new)
          the_db.should_receive(:bulk_save)
          @b1.bulk_save!(@uri)
        end
        
        describe "data" do
          it "should return an array of its contents' #data" do
            @b1.data.should == [ @a1.data ]
          end
        end
      end
      
      describe "reading" do
        before(:each) do
          @uri = "http://127.0.0.1/baz:5984"
        end
        
        it "create a new Batch" do
          Batch.load_tagged_answers(@uri,"foo").should be_a_kind_of(Batch)
        end
        
        it "should access the database" do
          CouchRest.should_receive(:database).with(@uri)
          Batch.load_tagged_answers(@uri, "workstation_1")
        end
        
        it "should work"
      end
      
    end
    
    
    it "should have a Batch.load_from_couch method that reads a bunch of Answers from the db"
    
  end
end