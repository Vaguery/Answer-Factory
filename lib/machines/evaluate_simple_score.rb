module AnswerFactory
  module Machines
    
    
    
    
    class EvaluateSimpleScore < Machine
      
      def score(batch, overridden_options = {}, &scorer)
        raise ArgumentError, "EvaluateSimpleScore#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        
        all_options = @options.merge(overridden_options)
        name = all_options[:name]
        
        raise ArgumentError, "EvaluateSimpleScore: Undefined #name attribute" if
          name.nil?
        
        batch.each do |answer|
          answer.scores[name] = if scorer.nil?
            12
          else
            scorer.call(answer)
          end
        end
        return batch
      end
      
      alias :generate :score
    end
  end
end