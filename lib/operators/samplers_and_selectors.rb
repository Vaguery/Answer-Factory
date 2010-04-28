module AnswerFactory
  
  class Sampler < SearchOperator
    def initialize (params = {})
      super
    end
    
    def all_known_criteria(crowd)
      union = []
      crowd.each do |dude|
        union |= dude.known_criteria
      end
      return union
    end
    
    
    def all_shared_scores(crowd)
      intersection = self.all_known_criteria(crowd)
      crowd.each do |dude|
        intersection = intersection & dude.known_criteria
      end
      return intersection
    end
    
    
    def domination_classes(crowd, template = all_shared_scores(crowd))
      result = Hash.new()
      
      crowd.each_index do |i|
        dominated_by = 0
        
        crowd.each_index do |j|
          dominated_by += 1 if crowd[i].dominated_by?(crowd[j], template)
        end
        
        result[dominated_by] ||= []
        result[dominated_by].push crowd[i]
      end
      
      return result
    end
    
    
    def diversity_classes(crowd)
      result = Hash.new()
      crowd.each do |dude|
        result[dude.program.tidy] ||= []
        result[dude.program.tidy] << dude
      end
      return result
    end
  end
  
  
  
  
  
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
  
  
  
  
  
  class DominatedQuantileSampler < Sampler
    def generate(crowd, proportion = 0.5, template = all_shared_scores(crowd))
      classified = domination_classes(crowd, template)
      increasing_grades = classified.keys.sort {|a,b| b <=> a}
      partial_ordering = []
      increasing_grades.each {|grade| partial_ordering += classified[grade]}
      how_many = (crowd.length * proportion).ceil
      
      result = Batch.new
      partial_ordering[0...how_many].each {|dude| result << dude} unless how_many == 0
      return result
    end
  end
  
  
  
  
  
  class MostDominatedSubsetSampler < Sampler
    def generate(crowd, template = all_shared_scores(crowd))
      result = Batch.new
      classified = domination_classes(crowd, template)
      worst_key = classified.keys.sort[-1]
      classified[worst_key].each {|bad_dude| result.push bad_dude}
      return result
    end
  end
  
  
  
  
  
  class AnyOneSampler < Sampler
    def generate(crowd)
      result = Batch[crowd.sample]
    end
  end
  
  
  
  
  
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