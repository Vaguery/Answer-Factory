module Machine::Nudge
  class ScoreLength < Machine
    options :score_name => :length
    
    path :of_scored
    
    def process (answers)
      answers.each do |answer|
        answer.score(@score_name, answer.blueprint.length)
      end
      
      send_answers(answers, path[:of_scored])
    end
  end
end
