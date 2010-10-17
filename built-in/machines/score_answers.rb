# encoding: UTF-8
class ScoreAnswers < Machine
  def score_with (scorer_class)
    @scorer_class = scorer_class
  end
  
  def process_answers
    @scorer_class || raise(SomeErrorClass, "no scorer")
    
    scores = Factory.score(answers, @scorer_class)
    Factory.save_scores(scores)
    
    return :scored => answers
  end
end
