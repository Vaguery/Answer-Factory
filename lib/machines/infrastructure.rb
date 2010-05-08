module AnswerFactory
  
  # Abstract class that from which specific SearchOperator subclasses inherit initialization
  
  class SearchOperator
    attr_accessor :incoming_options
    
     def initialize(options={})
       @incoming_options = options
     end
  end
  
  
  class Evaluator < SearchOperator
    attr_accessor :score_label
    
    def initialize(params = {})
      raise(ArgumentError, "Evaluators must have a score_label") if params[:score_label] == nil
      @score_label = params[:score_label]
    end
  end
  
  
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
end