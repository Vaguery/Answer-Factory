module AnswerFactory
  module Machines
    
    
    
    
    class SampleAnyOne < Machine
      
      def screen(batch)
        raise ArgumentError, "SampleAnyOne#screen: argument is not a Batch" unless
          batch.kind_of?(Batch)
        one = batch.sample
        return one.nil? ? Batch.new : Batch.[](one)
      end
      
      alias :generate :screen
    end
    
    
    
    
    class RemoveAnyOne < Machine
      
      def screen(batch)
        raise ArgumentError, "RemoveAnyOne#screen: argument is not a Batch" unless
          batch.kind_of?(Batch)
        working_copy = batch.dup
        where = rand(working_copy.length)
        working_copy.delete_at(where)
        return working_copy
      end
      
      alias :generate :screen
    end
    
    
  end
end