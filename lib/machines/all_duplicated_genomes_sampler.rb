module AnswerFactory
  
  class AllDuplicatedGenomesSampler < Sampler
    def generate(crowd)
      result = Batch.new
      clustered = diversity_classes(crowd)
      clustered.each do |blueprint, array|
        if array.length > 1
          result.concat array
        end
      end
      return result
    end
  end

end