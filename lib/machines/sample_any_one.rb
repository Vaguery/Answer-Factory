module AnswerFactory
  module Machines
    
    class SampleAnyOne < Machine
      
      def generate(batch)
        raise ArgumentError, "SampleAnyOne#generate: argument is not a Batch" unless
          batch.kind_of?(Batch)
        
        one = batch.sample
        return one.nil? ? Batch.new : Batch.[](one)
      end
    end
  end
end