module AnswerFactory
  
  class MostDominatedSubsetSampler < Sampler
    def generate(crowd, template = all_shared_scores(crowd))
      result = Batch.new
      classified = domination_classes(crowd, template)
      worst_key = classified.keys.sort[-1]
      classified[worst_key].each {|bad_dude| result.push bad_dude}
      return result
    end
  end
  
end