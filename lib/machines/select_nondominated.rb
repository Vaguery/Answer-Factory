module AnswerFactory
  module Machines
    
    
    
    
    class SelectNondominated < Machine

      def screen(batch, overriden_options={})
        raise ArgumentError, "SelectNondominated#screen cannot process class #{batch.class}" unless
          batch.kind_of?(Batch)
        all_options = @options.merge(overriden_options)
        
        criteria = all_options[:comparison_criteria]
        result = Batch.new
        
        batch.each do |a|
          if criteria.nil?
            winner = batch.inject(true) {|anded, b| anded && (!a.dominated_by?(b))}
          else
            winner = batch.inject(true) {|anded, b| anded && (!a.dominated_by?(b, criteria))}
          end
          result << a if winner
        end
        
        return result
      end
      
      alias :generate :screen
    end
  end
end