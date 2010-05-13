module AnswerFactory
  module Machines
    
    
    class EvaluateWithTestCases < Machine
      attr_accessor :dataset, :sensors
      
      def initialize(options = {})
        super
        @dataset = options[:dataset] || {}
        @sensors = options[:sensors] || {}
        
      end
      
      def score(batch, overridden_options = {})
        all_options = @options.merge(overridden_options)
        name = all_options[:name]
        
        raise ArgumentError, "EvaluateWithTestCases#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        raise ArgumentError, "EvaluateWithTestCases: Undefined #name attribute" if
          name.nil?
        
        
        return Batch.new
      end
      
      alias :generate :score
    end
    
    
    
    
    class TestCase
      attr_accessor :inputs, :outputs
      
      def initialize(options = {})
        @inputs = options[:inputs] || {}
        @outputs = options[:outputs] || {}
      end
    end
  end
end