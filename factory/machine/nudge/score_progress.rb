module Machine::Nudge
  class ScoreProgress < Machine
    options :score_name => :progress
    
    path :of_scored
    
    def process (answers)
      answers.each do |answer|
        answer.score(@score_name, -answer.progress)
      end
      
      send_answers(answers, path[:of_scored])
    end
  end
end
