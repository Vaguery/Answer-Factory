require File.join(File.dirname(__FILE__), "../spec_helper")

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
          the_db.stub!(:bulk_save).and_return([])
          CouchRest.should_receive(:database!)
          Batch.new.bulk_save!(@uri)
        end

        it "should bulk_save the Answers" do
          CouchRest.stub(:database!).and_return(the_db = Object.new)
          the_db.should_receive(:bulk_save).and_return([])
          @b1.bulk_save!(@uri)
        end
        
        it "should capture the _id and _rev from couch_db's response" do
          CouchRest.stub(:database!).and_return(the_db = Object.new)
          the_db.should_receive(:bulk_save).and_return(
            [{"id"=>"123", "rev"=>"4-567"}])
          @b1.bulk_save!(@uri)
          @b1[0].couch_id.should == "123"
          @b1[0].couch_rev.should == "4-567"
        end
        
        
        describe "data" do
          it "should return an array of its contents' #data" do
            @b1.data.should == [ @a1.data ]
            @b1 << @a1
            @b1.data.should == [ @a1.data,  @a1.data]
          end
        end
      end
      
      describe "reading" do
        before(:each) do
          @uri = "http://127.0.0.1:5984/my_factory"
          @design_doc = "ws1/current"  # we'll assume this has been set up!
          @view_uri = "http://127.0.0.1:5984/my_factory/_design/ws1/_view/current"
          FakeWeb.allow_net_connect = false
          @canned = '{"total_rows":1,"offset":0,"rows":[{"id":"0f60c293ad736abfdb083d33f71ef9ab","key":"ws1","value":{"_id":"0f60c293ad736abfdb083d33f71ef9ab","_rev":"1-473467b6dc1a4cba3498dd6eeb8e3206","blueprint":"do bar","tags":[],"scores":{},"progress":12,"timestamp":"2010/04/14 17:09:14 +0000"}}]}'
          
        end
        
        it "should connect to the right view in the right design doc in the persistent store" do
          FakeWeb.register_uri(:any, @view_uri, :body => @canned, :status => [200, "OK"])
          lambda{Batch.load_from_couch(@uri,@design_doc)}.should_not raise_error
            # because it hit the right URI!
        end
        
        describe "error-handling" do
          it "should handle errors returned from CouchDB"
          
          it "should handle 'resource not found'"
        end 
        
        it "should handle db connection problems"
        
        it "should create an Answer for every row received" do
          FakeWeb.register_uri(:any, @view_uri, :body => @canned, :status => [200, "OK"])
          little_batch = Batch.load_from_couch(@uri,@design_doc)
          little_batch.length.should == 1
          little_batch[0].blueprint.should == "do bar"
        end

        it "should raise an warning and create an empty Batch if it can't parse the result" do
          FakeWeb.register_uri(:any, @view_uri, :body => "some random crap", :status => [200, "OK"])
          little_batch = Batch.load_from_couch(@uri,@design_doc)
          little_batch.length.should == 0
        end
      end
      
    end
  end
end