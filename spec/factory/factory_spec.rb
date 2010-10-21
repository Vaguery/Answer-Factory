require File.dirname(__FILE__) + '/../spec_helper'
class FakeWorkstation < Workstation; end
describe Factory do
  describe "adding a workstation" do
    before(:each) do
      Factory.setup do
      end
      @workstation = Factory.workstation('sample', :FakeWorkstation)
    end
    
    it "adds it to the list of workstations by name" do
      Factory.instance_variable_get("@workstations").should include(:sample)
    end
    
    it "sets the machine class as the provided class name" do
      @workstation.class.should == FakeWorkstation
    end
    
    it "schedules the workstation by name in the order it was defined" do
      Factory.workstation('test', :FakeWorkstation)
      Factory.instance_variable_get("@schedule").should == [:sample, :test]
    end
  end
  
  describe "scheduling workstations" do
    before(:each) do
      Factory.setup do
      end
      Factory.workstation('sample', :Workstation)
      Factory.workstation('test', :Workstation)
      
    end
    
    it "occrus by name in the order it was defined" do
      Factory.instance_variable_get("@schedule").should == [:sample, :test]
    end
    
    it "can be declared in a specific order" do
      Factory.schedule(:test, :sample)
      Factory.instance_variable_get("@schedule").should == [:test, :sample]
    end
  end
  
  describe "using a database adapter" do
    it "extends Factory with database behevior" do
      Factory.should_not respond_to(:set_database)
      Factory.database('adapter' => 'mysql')
      Factory.should respond_to(:set_database)
    end
  end
  
  describe "running" do
    it "runs each workstation in the order specified forever" do
      pending
    end
  end
end