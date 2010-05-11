require File.join(File.dirname(__FILE__), "./../spec_helper")

# CouchDB MUST BE RUNNING BEFORE YOU RUN THESE


describe "CouchDB stuff" do
  before(:each) do
    configatron.factory.couchdb.server = "http://127.0.0.1:5984"
    configatron.factory.couchdb.name = "integration_test_db"
    break("CouchDB is offline") unless Factory.couch_available?
    @db_uri = "#{configatron.factory.couchdb.server}/#{configatron.factory.couchdb.name}"
  end
  
  describe "updating a Batch" do
    before(:each) do
      @batch = Batch.[](Answer.new("do a"), Answer.new("do b"))
    end
    
    it "should be possible to set the couchdb_id and have that be actually used" do
      @batch[0].couch_id = "001"
      @batch[1].couch_id = "002"
      ids = @batch.bulk_save!(@db_uri).collect {|r| r["id"]}
      puts ids
      ids.should == ["001", "002"]
    end
    
    it "should be possible to overwrite a document with new info" do
      db = CouchRest.database!(@db_uri)
      doc = CouchRest::Document.new({"_id" => "junk00001", "foo" => nil, "bar" => nil})
      doc.database = db
      puts doc.uri
      db.bulk_save_doc(doc)
      
      doc["foo"] = 1000
      doc.save
    end
    
    it "should be possible to overwrite the same Answers with new info" do
      @batch[0].couch_id = "003"
      @batch[1].couch_id = "004"
      ids = @batch.bulk_save!(@db_uri).collect {|r| r["id"]}
      ids.should == ["003", "004"]
      @batch[0].couch_id.should == "003"

    end
    
    
    # 
    # 
    # it "should capture the returned IDs and save them from the couch response hash" do
    #   response = @batch.bulk_save!(@db_uri)
    #   ids = response.collect {|r| r["id"]}
    #   @batch.each {|a| ids.should include(a.couch_id)}
    # end
    # 
    
  end
  
end