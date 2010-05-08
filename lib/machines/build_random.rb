module AnswerFactory
  module Machines
    
    
    
    
    class BuildRandom < Machine
      
      
      def build(overridden_options = {})
        all_options = @options.merge(overridden_options)
        how_many = all_options[:how_many] || 1
        result = Batch.new
        how_many.times {result << Answer.new(NudgeProgram.random(all_options))}
        return result
      end
    end
  end
end