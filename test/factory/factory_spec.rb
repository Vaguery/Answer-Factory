require 'answer_factory'

describe "Factory" do
  describe ".use (db_library: Symbol)" do
    it "returns the Factory singleton" do
      Factory.use(:data_mapper).should == Factory
    end
    
    it "loads the specified database library" do
      Factory.use(:data_mapper)
      lambda { DataMapper }.should_not raise_error
    end
  end
  
  describe ".run" do
    it "calls run once on each item in the Factory schedule" do
      item_1 = mock(:schedule_item)
      item_2 = mock(:schedule_item)
      
      item_1.should_receive(:run).exactly(1).times
      item_2.should_receive(:run).exactly(2).times
      
      Factory.instance_variable_set(:@schedule, ([item_1, item_2, item_2]))
      Factory.run
    end
    
    describe "(n: Fixnum)" do
      it "calls run n times on each item in the Factory schedule" do
        item_1 = mock(:schedule_item)
        item_2 = mock(:schedule_item)
        
        item_1.should_receive(:run).exactly(3).times
        item_2.should_receive(:run).exactly(6).times
        
        Factory.instance_variable_set(:@schedule, ([item_1, item_2, item_2]))
        Factory.run(3)
      end
    end
  end
end
