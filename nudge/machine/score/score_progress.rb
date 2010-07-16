module Machine::Nudge
  class ScoreProgress < Machine
    paths :scored
    
    options :score_name => :progress
    
    def process (answers)
      answers.each do |answer|
        answer.score(@score_name => -answer.progress)
      end
      
      return :scored => answers
    end
  end
end
