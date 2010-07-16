module Machine::Nudge
  class ScoreLength < Machine
    paths :scored
    
    options :score_name => :length
    
    def process (answers)
      answers.each do |answer|
        answer.score(@score_name => answer.blueprint.length)
      end
      
      return :scored => answers
    end
  end
end
