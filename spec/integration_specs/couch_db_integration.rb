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
    
    it "should capture the returned IDs and save them from the couch response hash" do
      response = @batch.bulk_save!(@db_uri)
      ids = response.collect {|r| r["id"]}
      @batch.each {|a| ids.should include(a._id)}
    end
    
    it "should be possible to overwrite the same Answers with new info" do
      ids_1 = @batch.bulk_save!(@db_uri).collect {|r| r["id"]}
      @batch[0].scores[:foo] = 88
      @batch[1].scores[:foo] = 99
      ids_2 = @batch.bulk_save!(@db_uri).collect {|r| r["id"]}
      puts ids_2
      puts ids_1
    end
    
  end
  
end