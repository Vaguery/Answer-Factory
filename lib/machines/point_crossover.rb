#encoding: utf-8
module AnswerFactory
  module Machines
    
    
    
    
    class PointCrossover < Machine
      
      def build(batch, overridden_options={})
        raise ArgumentError, "PointCrossover#build cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        
        all_options = @options.merge(overridden_options)
          
        replicates = all_options[:replicates] || 1
        
        result = Batch.new
        number_of_parents = batch.length
        
        batch.each do |answer|
          replicates.times do
            parents = batch.sample(2)
            mom = parents[0]
            dad = parents[1]
            
            mom_point = Kernel.rand(mom.points)+1
            
            dad_point = Kernel.rand(dad.points)+1
            dad_code = dad.program[dad_point].blueprint
            
            baby = mom.replace_point_or_clone(mom_point,dad_code)
            baby_progress = [dad.progress, mom.progress].max + 1

            result << Answer.new(baby, progress:baby_progress)
          end
        end
        
        return result
      end
      
      
      alias :generate :build
      
      
    end
  end
end