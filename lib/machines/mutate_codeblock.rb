#encoding: utf-8
module AnswerFactory
  module Machines
    
    
    
    
    class MutateCodeblock < Machine
      
      def build(batch, overridden_options={})
        raise ArgumentError, "MutateCodeblock#build cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        
        all_options = @options.merge(overridden_options)
          
        replicates = all_options[:replicates] || 1
        
        result = Batch.new
        
        batch.each do |answer|
          replicates.times do
            which_point = rand(answer.points) + 1
            size = all_options[:size_preserving?] ?
              answer.program[which_point].points :
              Kernel.rand(2 * answer.program[which_point].points) + 1
            new_code = NudgeType::CodeType.any_value(all_options.merge({target_size_in_points:size}))
            mutated_code = answer.replace_point_or_clone(which_point, new_code)
            variant = Answer.new(mutated_code, progress:answer.progress + 1)
            result << variant
          end
        end
        
        return result
      end
      
      
      alias :generate :build
      
      
    end
  end
end