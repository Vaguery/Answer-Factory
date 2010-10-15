# encoding: UTF-8
class Answer
  def initialize (blueprint)
    @blueprint = blueprint
    @language = blueprint.language
    @scores = {}
    
    @blueprint.force_encoding("utf-8") if "".respond_to?(:force_encoding)
  end
  
  def blueprint
    @blueprint
  end
  
  def language
    @language
  end
  
  def id
    @id
  end
  
  def location
    @location
  end
  
  def assign (location)
    @location = location
    self
  end
  
  def score (score_name)
    (score = @scores[score_name.to_sym]) ? score.value : Factory::Infinity
  end
  
  def has_score? (score_name)
    @scores.has_key?(score_name.to_sym)
  end
  
  def nondominated_vs? (other, criteria)
    nondominated_vs_other = true
    
    criteria.each do |score_name|
      self_score = self.score(score_name)
      other_score = other.score(score_name)
      
      if self_score < other_score
        nondominated_vs_other = true
        break
      elsif nondominated_vs_other
        nondominated_vs_other &&= (self_score == other_score)
      end
    end
    
    nondominated_vs_other
  end
end
