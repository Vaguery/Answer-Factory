module AnswerFactory
  module Machines
    
    
    
    
    class EvaluateSimpleScore < Machine
      
      def score(batch, overridden_options = {}, &score_block)
        all_options = @options.merge(overridden_options)
        name = all_options[:name]
        scorer = score_block || all_options[:scorer]
        
        raise ArgumentError, "EvaluateSimpleScore#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        raise ArgumentError, "EvaluateSimpleScore: Undefined #name attribute" if
          name.nil?
        raise ArgumentError, "EvaluateSimpleScore: No scoring block available" if
          scorer.nil?
        
        batch.each do |answer|
          all_options[:static_score?] ?
            (answer.scores[name] ||= scorer.call(answer)) :
            (answer.scores[name] = scorer.call(answer))
        end
        return batch
      end
      
      alias :generate :score
    end
  end
end