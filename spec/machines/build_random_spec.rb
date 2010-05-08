require File.join(File.dirname(__FILE__), "./../spec_helper")

describe "Machines::BuildRandom" do
  
  
  describe "#build method" do
    
    before(:each) do
      @basic_maker = Machines::BuildRandom.new
    end
    
    it "should respond to :build" do
      @basic_maker.should respond_to(:build)
    end
    
    it "should return a Batch" do
      @basic_maker.build.should be_a_kind_of(Batch)
    end
    
    it "should accept an option :how_many to set the number of items in the Batch" do
      @basic_maker.build(how_many:12).length.should == 12
    end
    
    it "should use the initialized :how_many parameter if not passed one in the call" do
      Machines::BuildRandom.new(how_many:9).build.length.should == 9
    end
    
    it "should use how_many:1 if it had none in #new or #build args" do
      Machines::BuildRandom.new.build.length.should == 1
    end
    
    it "should call NudgeProgram.random for each new Answer it makes" do
      NudgeProgram.should_receive(:random).exactly(4).times.and_return(NudgeProgram.new("do a"))
      @basic_maker.build(how_many:4)
    end
    
    it "should pass a merge of its saved options and the #build options to NudgeProgram.random" do
      NudgeProgram.should_receive(:random).
        with(hash_including(target_size_in_points:12)).
        and_return(NudgeProgram.new("foo"))
      @basic_maker.build(how_many:1, target_size_in_points:12)
      
      NudgeProgram.should_receive(:random).
        with(hash_including(reference_names:["x1", "x2"])).
        and_return(NudgeProgram.new("bar"))
      Machines::BuildRandom.new(reference_names:["x1", "x2"]).
        build(how_many:1)
    end
    
    it "should just produce the expected result without any options at all" do
      whatevz = @basic_maker.build
      whatevz.should be_a_kind_of(Batch)
      whatevz.each {|a| a.parses?.should == true}
    end
  end
end