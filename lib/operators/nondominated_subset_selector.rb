module AnswerFactory
  class NondominatedSubsetSelector < Sampler
    
    def generate(crowd, template = all_shared_scores(crowd))
      result = Batch.new
      crowd.each do |answer|
        dominated = false
        crowd.each do |other_answer|
          dominated ||= answer.dominated_by?(other_answer, template)
        end
        result << answer unless dominated
      end
      return result
    end
  end
  
end