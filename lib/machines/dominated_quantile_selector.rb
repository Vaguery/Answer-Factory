module AnswerFactory
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
  
end