module AnswerFactory
  module Machines
    
    
    
    
    class BuildRandom < Machine
      
      
      def build(batch = nil, overridden_options = {})
        all_options = @options.merge(overridden_options)
        how_many = all_options[:how_many] || 1
        result = Batch.new
        how_many.times {result << Answer.new(NudgeProgram.random(all_options))}
        return result
      end
      
      alias generate build
    end
  end
end