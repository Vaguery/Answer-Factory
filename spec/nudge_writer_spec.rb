# encoding: UTF-8
require 'spec_helper'

describe "NudgeWriter" do
  describe ".new" do
    it "sets @footnotes_needed to []" do
      NudgeWriter.new.instance_variable_get(:@footnotes_needed).should == []
    end
    
    it "sets @block_width to 5" do
      NudgeWriter.new.instance_variable_get(:@block_width).should == 5
    end
    
    it "sets @block_depth to 5" do
      NudgeWriter.new.instance_variable_get(:@block_depth).should == 5
    end
    
    it "sets @code_recursion to 5" do
      NudgeWriter.new.instance_variable_get(:@code_recursion).should == 5
    end
    
    it "defines all instruction names as available do_instructions" do
      NudgeWriter.new.instance_variable_get(:@do_instructions).should == NudgeInstruction::INSTRUCTIONS.keys
    end
    
    it "defines :x1 through :x10 as available ref_names" do
      NudgeWriter.new.instance_variable_get(:@ref_names).should == [:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end
    
    it "defines :bool, :code, :float, :int, and :proportion as available value_types" do
      value_types = NudgeWriter.new.instance_variable_get(:@value_types)
      code_type = NudgeWriter.new.instance_variable_get(:@code_type_switch)
      (value_types + code_type).should == [:bool, :float, :int, :proportion, :code]
    end
    
    it "gives equal probability distribution to :block, :do, :ref, and :value points" do
      writer = NudgeWriter.new
      writer.instance_variable_get(:@block).should == (0...0.25)
      writer.instance_variable_get(:@do).should == (0.25...0.5)
      writer.instance_variable_get(:@ref).should == (0.5...0.75)
    end
    
    it "defines the range of :float literals as -100 to 100" do
      writer = NudgeWriter.new
      writer.instance_variable_get(:@min_float).should == -100.0
      writer.instance_variable_get(:@max_float).should == 100.0
    end
    
    it "defines the range of :int literals as -100 to 100" do
      writer = NudgeWriter.new
      writer.instance_variable_get(:@min_int).should == -100
      writer.instance_variable_get(:@max_int).should == 100
    end
  end
  
  describe ".new {|writer| config }" do
    it "executes the configuration block" do
      lambda { NudgeWriter.new { raise "x" } }.should raise_error "x"
    end
  end
  
  describe "#do_instructions= (*instruction_names: [Symbol, *])" do
    it "sets @do_instructions" do
      writer = NudgeWriter.new
      writer.do_instructions = [:int_add, :int_subtract]
      
      writer.instance_variable_get(:@do_instructions).should == [:int_add, :int_subtract]
    end
    
    it "disallows keyword instruction names" do
      writer = NudgeWriter.new
      writer.do_instructions = [:int_add, :block, :do, :ref, :value]
      
      writer.instance_variable_get(:@do_instructions).should == [:int_add]
    end
  end
  
  describe "#ref_names= (*ref_names: [Symbol, *])" do
    it "sets @ref_names" do
      writer = NudgeWriter.new
      writer.ref_names = [:x, :y]
      
      writer.instance_variable_get(:@ref_names).should == [:x, :y]
    end
    
    it "disallows keyword ref names" do
      writer = NudgeWriter.new
      writer.ref_names = [:x, :block, :do, :ref, :value]
      
      writer.instance_variable_get(:@ref_names).should == [:x]
    end
  end
  
  describe "#value_types= (*value_types: [Symbol, *])" do
    it "sets @value_types" do
      writer = NudgeWriter.new
      writer.value_types = [:int, :float]
      
      writer.instance_variable_get(:@value_types).should == [:int, :float]
    end
    
    it "disallows keyword value types" do
      writer = NudgeWriter.new
      writer.value_types = [:int, :block, :do, :ref, :value]
      
      writer.instance_variable_get(:@value_types).should == [:int]
    end
    
    it "disallows :name, :exec, and :error value types" do
      writer = NudgeWriter.new
      writer.value_types = [:int, :name, :exec, :error]
      
      writer.instance_variable_get(:@value_types).should == [:int]
    end
  end
  
  describe "#weight= (weight: Hash)" do
    it "sets @block probability range" do
      writer = NudgeWriter.new
      writer.weight = {:block => 10, :do => 30, :ref => 20, :value => 40}
      
      writer.instance_variable_get(:@block).should == (0...0.1)
    end
    
    it "sets @do probability range" do
      writer = NudgeWriter.new
      writer.weight = {:block => 10, :do => 30, :ref => 20, :value => 40}
      
      writer.instance_variable_get(:@do).should == (0.1...0.4)
    end
    
    it "sets @ref probability range" do
      writer = NudgeWriter.new
      writer.weight = {:block => 10, :do => 30, :ref => 20, :value => 40}
      
      writer.instance_variable_get(:@ref).should == (0.4...0.6)
    end
  end
  
  describe "#float_range= (range: Range)" do
    it "sets @min_float" do
      writer = NudgeWriter.new
      writer.float_range = 50..10
      
      writer.instance_variable_get(:@min_float).should == 10
    end
    
    it "sets @max_float" do
      writer = NudgeWriter.new
      writer.float_range = 5..10
      
      writer.instance_variable_get(:@max_float).should == 10
    end
  end
  
  describe "#int_range= (range: Range)" do
    it "sets @min_float" do
      writer = NudgeWriter.new
      writer.int_range = 50..10
      
      writer.instance_variable_get(:@min_int).should == 10
    end
    
    it "sets @max_float" do
      writer = NudgeWriter.new
      writer.int_range = 5..10
      
      writer.instance_variable_get(:@max_int).should == 10
    end
  end
  
  describe "#random" do
    it "returns a valid Nudge script" do
      script = NudgeWriter.new.random
      NudgePoint.from(script).should_not be_a NilPoint
    end
  end
  
  describe "#random_value (value_type: Symbol)" do
    it "returns a script that parses as a single ValuePoint of value_type" do
      script = NudgeWriter.new.random_value(:int)
      point = NudgePoint.from(script)
      
      point.should be_a ValuePoint
      point.instance_variable_get(:@value_type).should == :int
    end
  end
end
