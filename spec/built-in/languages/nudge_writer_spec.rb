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
  
  describe "#use_instructions (*instruction_names: [Symbol, *])" do
    it "sets @do_instructions" do
      writer = NudgeWriter.new
      writer.use_instructions(:int_add, :int_subtract)
      
      writer.instance_variable_get(:@do_instructions).should == [:int_add, :int_subtract]
    end
    
    it "disallows keyword instruction names" do
      writer = NudgeWriter.new
      writer.use_instructions :int_add, :block, :do, :ref, :value
      
      writer.instance_variable_get(:@do_instructions).should == [:int_add]
    end
  end
  
  describe "#use_refs (*ref_names: [Symbol, *])" do
    it "sets @ref_names" do
      writer = NudgeWriter.new
      writer.use_refs :x, :y
      
      writer.instance_variable_get(:@ref_names).should == [:x, :y]
    end
    
    it "disallows keyword ref names" do
      writer = NudgeWriter.new
      writer.use_refs :x, :block, :do, :ref, :value
      
      writer.instance_variable_get(:@ref_names).should == [:x]
    end
  end
  
  describe "#use_random_values (*value_types: [Symbol, *])" do
    it "sets @value_types" do
      writer = NudgeWriter.new
      writer.use_random_values :int, :float
      
      writer.instance_variable_get(:@value_types).should == [:int, :float]
    end
    
    it "disallows keyword value types" do
      writer = NudgeWriter.new
      writer.use_random_values :int, :block, :do, :ref, :value
      
      writer.instance_variable_get(:@value_types).should == [:int]
    end
    
    it "disallows :name, :exec, and :error value types" do
      writer = NudgeWriter.new
      writer.use_random_values :int, :name, :exec, :error
      
      writer.instance_variable_get(:@value_types).should == [:int]
    end
  end
  
  describe "#weight (weight: Hash)" do
    it "sets @block probability range" do
      writer = NudgeWriter.new
      writer.weight( block:10, do:30, ref:20, value:40 )
      
      writer.instance_variable_get(:@block).should == (0...0.1)
    end
    
    it "sets @do probability range" do
      writer = NudgeWriter.new
      writer.weight( block:10, do:30, ref:20, value:40 )
      
      writer.instance_variable_get(:@do).should == (0.1...0.4)
    end
    
    it "sets @ref probability range" do
      writer = NudgeWriter.new
      writer.weight( block:10, do:30, ref:20, value:40 )
      
      writer.instance_variable_get(:@ref).should == (0.4...0.6)
    end
    
    it "assumes any unspecified key has value 0" do
      writer = NudgeWriter.new
      writer.weight(do:2, ref:2, value:3)
      
      writer.instance_variable_get(:@block).should == (0.0...0.0)
    end
    
    it "ignores any key-value pairs for keys not in [:block, :do, :ref, :value]" do
      writer = NudgeWriter.new
      lambda{writer.weight(block:2, do:2, ref:2, value:2, foo:8)}.should_not raise_error
      writer.instance_variable_get(:@do).should == (0.25...0.5)
    end
  end
  
  describe "#float_range (range: Range)" do
    it "sets @min_float" do
      writer = NudgeWriter.new
      writer.float_range 50..10
      
      writer.instance_variable_get(:@min_float).should == 10
    end
    
    it "sets @max_float" do
      writer = NudgeWriter.new
      writer.float_range 5..10
      
      writer.instance_variable_get(:@max_float).should == 10
    end
  end
  
  describe "#int_range (range: Range)" do
    it "sets @min_float" do
      writer = NudgeWriter.new
      writer.int_range 50..10
      
      writer.instance_variable_get(:@min_int).should == 10
    end
    
    it "sets @max_float" do
      writer = NudgeWriter.new
      writer.int_range 5..10
      
      writer.instance_variable_get(:@max_int).should == 10
    end
  end
  
  describe "#random" do
    it "should make a block" do
      dummy = NudgeWriter.new
      dummy.block_width 1
      puts dummy.random
    end
    
    it "should use the settings specified elsewhere" do
      pending "what needs to be specced?"
      boring_writer = NudgeWriter.new
      boring_writer.block_width 10
      boring_writer.block_depth 0
      boring_writer.int_range 13...13
      boring_writer.use_instructions :float_add
      boring_writer.use_refs :t66
      boring_writer.use_random_values :int
      puts boring_writer.random
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
  
  describe "values" do
    describe ":int defaults" do
      it "should be an :int in the range given, inclusive" do
        writer = NudgeWriter.new
        writer.int_range 123...456
        writer.generate_value(:int)
        Random.should_receive(:rand).with(333.0)
        writer.generate_footnotes
      end
      
      it "should handle 0-width ranges" do
        writer = NudgeWriter.new
        writer.int_range 123...123
        writer.generate_value(:int)
        Random.should_receive(:rand).with(0.0).and_return(0.5)
        writer.generate_footnotes.should match(/123$/)
      end
    end
    
    describe ":float defaults" do
      it "should be an :float in the range given, inclusive" do
        writer = NudgeWriter.new
        writer.float_range 123...456
        writer.generate_value(:float)
        Random.should_receive(:rand).with(no_args()).and_return(0.0)
        writer.generate_footnotes.should match(/123.0$/)
      end
      
      it "should handle 0-width ranges" do
        writer = NudgeWriter.new
        writer.float_range 0.333...0.333
        writer.generate_value(:float)
        Random.should_receive(:rand).with(no_args()).and_return(0.123)
        writer.generate_footnotes.should match(/0.333$/)
      end
    end
    
    describe ":bool defaults" do
      it "should be a coin flip" do
        writer = NudgeWriter.new
        writer.generate_value(:bool)
        Random.should_receive(:rand).with(no_args()).and_return(0.1)
        writer.generate_footnotes.should match(/true$/)
      end
    end
    
    describe ":code defaults" do
      it "should invoke a recursive call to #generate_block" do
        writer = NudgeWriter.new
        writer.generate_value(:code)
        writer.should_receive(:generate_block).with(any_args())
        writer.generate_footnotes
      end
    end
    
    describe ":proportion defaults" do
      it "should be a :proportion you get when you call Random.rand()" do
        writer = NudgeWriter.new
        writer.generate_value(:proportion)
        Random.should_receive(:rand).with(no_args()).and_return(0.0)
        writer.generate_footnotes
      end
    end
  end
  
end
