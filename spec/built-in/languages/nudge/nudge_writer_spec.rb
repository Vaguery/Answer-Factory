# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../spec_helper'

describe NudgeWriter do
  before(:each) do
    @writer = NudgeWriter.new
  end
  
  it "langauge name is :Nudge" do
    @writer.language.should == :Nudge
  end
  
  describe "block depth" do
    it "is ignored if block width is 1" do
      @writer.block_depth(15)
      @writer.block_width(1)
      @writer.use_instructions :int_add
      
      Random.should_receive(:rand).and_return(0,0,0.25)
      
      @writer.random.should == "do int_add\n"
    end
  end
  
  describe "block depth" do
    before(:each) do
      @writer.block_width(2)
      @writer.use_instructions :int_add
    end
    
    it "defaults to 5" do      
      Random.should_receive(:rand).exactly(12).times.and_return(0, 0, 0, 0, 0, 0.25)
      @writer.random.should == "block { block { block { block { block { block { do int_add do int_add } do int_add } do int_add } do int_add } do int_add } do int_add }\n"
    end
    
    it "is set with block_depth" do
      Random.should_receive(:rand).exactly(14).times.and_return(0, 0, 0, 0, 0, 0, 0.25)
      
      @writer.block_depth(6)
      @writer.random.should == "block { block { block { block { block { block { block { do int_add do int_add } do int_add } do int_add } do int_add } do int_add } do int_add } do int_add }\n"
    end
  end
  
  describe "block width" do
    before(:each) do
      @writer.block_depth(1)
      @writer.use_instructions :int_add
    end
        
    it "defaults to 5" do
      Random.should_receive(:rand).exactly(5).times.and_return(0.25)
      @writer.random.should == "block { do int_add do int_add do int_add do int_add do int_add }\n"
    end
    
    it "is set with block_width" do
      @writer.block_width(6)
      Random.should_receive(:rand).exactly(6).times.and_return(0.25)
      @writer.random.should == "block { do int_add do int_add do int_add do int_add do int_add do int_add }\n"
    end
  end
  
  describe "code recursion depth" do
    it "defaults to 5" do
      pending
    end
    
    it "is set with block_depth" do
      pending
      @writer.code_recursion(10)
    end
  end
  
  describe "core language construct weights for block generation" do
    it "default to equal weight for each construct" do
      @writer.block_width(1)
      @writer.use_instructions :int_add
      @writer.use_refs :y
      @writer.stub!(:generate_value).and_return("value «float»")
      
      # first two calls occur from the first call to generate_block
      # 0: block call
      # 0.25 recursive generate_block from block call
      Random.should_receive(:rand).and_return(0, 0.25, 0.25, 0.5, 0.75)
      @writer.generate_block(1).should == "do int_add"
      @writer.generate_block(1).should == "do int_add"
      @writer.generate_block(1).should == "ref y"
      @writer.generate_block(1).should == "value «float»"
    end
    
    it "can be set with weight method" do
      @writer.weight({
        :block => 5,
        :do => 10,
        :ref => 5,
        :value => 5
      })
      @writer.block_width(1)
      @writer.use_instructions :int_add
      @writer.use_refs :y
      @writer.stub!(:generate_value).and_return("value «float»")
      
      # first two calls occur from the first call to generate_block
      # 0: block call
      # 0.2 recursive generate_block call from block call
      Random.should_receive(:rand).and_return(0, 0.2, 0.2, 0.6, 0.8)
      @writer.generate_block(1).should == "do int_add"
      @writer.generate_block(1).should == "do int_add"
      @writer.generate_block(1).should == "ref y"
      @writer.generate_block(1).should == "value «float»"
    end
  end
  
  describe "float range" do
    it 'defaults to -100 to 100' do
      pending
    end
    
    it 'can be set to a range' do
      pending
    end
    
    it 'can be set to a range in reverse order' do
      pending
    end
  end
  
  describe "int range" do
    it 'defaults to -100 to 100' do
      pending
    end
    
    it 'can be set to a range' do
      pending
    end
    
    it 'can be set to a range in reverse order' do
      pending
    end
  end

  describe "available reference names" do    
    it "defaults to x1 through x10" do
      pending
      @writer.instance_variable_get("@ref_names").should == [:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end
    
    it "are set with use_refs" do
      pending
      @writer.use_refs :y5, :image
      @writer.instance_variable_get("@ref_names").should == [:y5, :image]
    end
    
    it "guards against mistakingly adding language constructs as references" do
      [:block, :do, :ref, :value].each do |core_language_construct_name|
        @writer.use_refs :y5, :photo, core_language_construct_name
        @writer.instance_variable_get("@ref_names").should_not include(core_language_construct_name)
      end
    end
  end
  
  describe "available instructions" do
    it "defaults to all Nudge instructions" do
      @writer.instance_variable_get("@do_instructions").should == NudgeInstruction::INSTRUCTIONS.keys
    end
    
    it "are set with use_instructions" do
      @writer.use_instructions :foo_mix, :foo_splice
      @writer.instance_variable_get("@do_instructions").should == [:foo_mix, :foo_splice]
    end
    
    it "guards against mistakingly adding language constructs as instructions" do
      [:block, :do, :ref, :value].each do |core_language_construct_name|
        @writer.use_instructions :foo_mix, :foo_splice, core_language_construct_name
        @writer.instance_variable_get("@do_instructions").should_not include(core_language_construct_name)
      end
    end
  end
  
  describe "generating a value" do
    it "generates a value of the provided type" do
      @writer.generate_value('float').should == 'value «float»'
    end
    
    it "stores a footnote stub for later addition" do
      @writer.generate_value('float')
      @writer.instance_variable_get("@footnotes_needed").should == ['float']
    end
    
    it "selects a random value type from available value type" do
      @writer.use_random_values :shirt
      @writer.generate_value.should == 'value «shirt»'
    end
  end
  
  describe "generating a footnote" do
  end
end