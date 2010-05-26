module AnswerFactory
  module Machines
    
    
    
    
    class SelectBySummedRank < Machine
      
      def screen(batch, overriden_options={})
        raise ArgumentError, "SelectBySummedRank#screen cannot process class #{batch.class}" unless
          batch.kind_of?(Batch)
        all_options = @options.merge(overriden_options)
        
        criteria = all_options[:comparison_criteria] || shared_goals(batch)
        return batch if criteria.empty?
        
        scored = Hash.new(0)
        incomparable = Set.new
        
        criteria.each do |criterion|
          scorable, unscorable = batch.partition {|a| a.scores.include?(criterion)}
          incomparable += unscorable
          ranked = scorable.sort_by {|a| a.scores[criterion]}
          ranked.each_with_index do |a, index|
            scored[a] += index
          end
        end
        
        incomparable.each {|a| scored.delete(a)}
        
        lowest_sum = scored.values.min
        winners = batch.find_all {|a| scored[a] == lowest_sum }
        
        result = Batch.new
        incomparable.each {|a| result << a}
        
        winners.each {|a| result << a unless result.include?(a)}
        return result
      end
      
      
      def all_goals(batch)
        (batch.collect {|a| a.scores.keys}).flatten.to_set.to_a
      end
      
      
      def shared_goals(batch)
        batch.inject(all_goals(batch)) {|intersection, answer| intersection &= answer.scores.keys}
      end
      
      alias :generate :screen
    end
  end
end