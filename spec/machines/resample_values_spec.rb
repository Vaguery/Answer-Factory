#encoding: utf-8
require File.join(File.dirname(__FILE__), "./../spec_helper")


describe "ResampleValuesOperator search operator" do
  
  it "should not need any initial parameters" do
    lambda{ResampleValuesOperator.new()}.should_not raise_error
  end
  
  it "should be possible to pass in stored parameters" do
    lambda{ResampleValuesOperator.new(randomIntegerLowerBound: 12)}.should_not raise_error
    rs = ResampleValuesOperator.new({boolTrueProbability: 0.2})
    rs.incoming_options.should include(:boolTrueProbability)
  end
  
  describe "generate" do
    before(:each) do
      @rs = ResampleValuesOperator.new({boolTrueProbability: 0.2})
      @intDude = Answer.new("block {value «int»}\n«int» 3")
      @boolDude = Answer.new("block {value «bool»}\n«bool» false")
      @floatDude = Answer.new("block {value «float»}\n«float» -991.2213")
      @complicatedDude = Answer.new(
        "block {value «int» value «bool» block {value «float»}}\n«int» 3\n«bool» false\n«float» 0.0")
    end
    
    it "should require a Batch as a first parameter" do
      lambda{@rs.generate()}.should raise_error(ArgumentError)
      lambda{@rs.generate(Batch.new)}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an ArgumentError if the array parameter isn't all Answers" do
      lambda{@rs.generate([88])}.should raise_error(ArgumentError)
      lambda{@rs.generate([@intDude])}.should_not raise_error(ArgumentError)
    end
    
    it "should by default produce one (1) resampled mutant for each input" do
      @rs.generate([@intDude]).length.should == 1
      @rs.generate([@intDude, @intDude]).length.should == 2
    end
    
    it "should call #any_value for each line in each individual that is a 'sample'" do
      IntType.should_receive(:any_value).and_return(777)
      newGuys = @rs.generate([@intDude])
      
      BoolType.should_receive(:any_value).and_return(false)
      newGuys = @rs.generate([@boolDude])
      
      FloatType.should_receive(:any_value).and_return(9.999)
      newGuys = @rs.generate([@floatDude])
      
      IntType.should_receive(:any_value).and_return(777)
      BoolType.should_receive(:any_value).and_return(false)
      FloatType.should_receive(:any_value).and_return(9.999)
      newGuys = @rs.generate([@complicatedDude])
      
      IntType.should_receive(:any_value).and_return(1,2)
      BoolType.should_receive(:any_value).and_return(false,true)
      FloatType.should_receive(:any_value).and_return(1.0,2.0)
      oldGuys = [@intDude,@boolDude,@floatDude,@complicatedDude]
      newGuys = @rs.generate(oldGuys,1)
    end
    
    it "should be possible to pass in a higher integer, and get that many variants for each input" do
      IntType.should_receive(:any_value).and_return(11,22,33)
      newGuys = @rs.generate([@intDude],3)
      newGuys[0].blueprint.should include("11")
      newGuys[1].blueprint.should include("22")
      newGuys[2].blueprint.should include("33")
      
      IntType.should_receive(:any_value).and_return(4,5,6,7)
      newGuys = @rs.generate([@intDude, @intDude],2)
    end
    
    it "should be using the Operator's saved parameters as a default behavior" do
      wholeLottaParams = {
        :randomIntegerLowerBound => 1000,
        :randomIntegerUpperBound => 1005,
        :randomBooleanTruthProb => 0.2,
        :randomFloatLowerBound => 112.0,
        :randomFloatUpperBound => 112.5}
      
      resampleLimited = ResampleValuesOperator.new(wholeLottaParams)
      
      IntType.should_receive(:any_value).with(hash_including(wholeLottaParams))
      newGuys = resampleLimited.generate([@intDude])
      
      BoolType.should_receive(:any_value).with(hash_including(wholeLottaParams))
      newGuys = resampleLimited.generate([@boolDude])
      
      FloatType.should_receive(:any_value).with(hash_including(wholeLottaParams))
      newGuys = resampleLimited.generate([@floatDude])
    end
    
    it "should return Answers who (probably) differ from the originals passed in" do
      outOfRangeParams = {
        :randomIntegerLowerBound => 1000,
        :randomIntegerUpperBound => 1005,
        :randomBooleanTruthProb => 1.0,
        :randomFloatLowerBound => 112.0,
        :randomFloatUpperBound => 112.5}
      resampleFarAway = ResampleValuesOperator.new(outOfRangeParams)
      newGuys = resampleFarAway.generate([@intDude])
      newGuys[0].blueprint.should =~ /100[0-5]/
      newGuys = resampleFarAway.generate([@boolDude])
      newGuys[0].blueprint.should =~ /true/
      newGuys = resampleFarAway.generate([@floatDude])
      newGuys[0].blueprint.should =~ /112\.[0-5]/
    end
    
    it "should be possible to temporarily override some or all of the preset @params" do
      bigInt = {:randomIntegerLowerBound => 90000,:randomIntegerUpperBound => 91000}
      toBeOverridden = ResampleValuesOperator.new(bigInt)
      defaults = toBeOverridden.generate([@intDude],5)
      defaults.each {|dude| dude.blueprint.should =~ /9\d\d\d\d/}
      
      littler = toBeOverridden.generate([@intDude],5,
        :randomIntegerLowerBound => -19, :randomIntegerUpperBound => -10)
      littler.each {|dude| dude.blueprint.should =~ /-1\d/}
    end
    
    it "should increment the #progress of every clone" do
      @complicatedDude.stub!(:progress).and_return(192)
      @rs.generate([@complicatedDude],5).each {|clone| clone.progress.should == 193}
    end
    
    it "should leave unrecognized types with footnote values in place" do
      hunh = Answer.new("value «foo»\n«foo» bar")
      ResampleValuesOperator.new.generate([hunh])[0].blueprint.should include("bar")
    end
    
    it "should work with CodeType footnotes, and reduce the number of points in each successive call"
  end
  
end