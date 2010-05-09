module AnswerFactory
  module Machines
    
    
    
    
    class VaryValuesUniformly < Machine
      
      def build(batch)
        raise ArgumentError, "EvaluateSimpleScore#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        result = Batch.new
      end
      
      alias :generate :build
    end
  end
end