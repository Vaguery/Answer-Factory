module Machine::Nudge
  class ScoreErrors < Machine
    options :score_name => :errors
    
    path :of_scored
    
    def process (answers)
      answers.each do |answer|
        outcome = Executable.new(answer.blueprint).run
        answer.score(@score_name, outcome.stacks[:error].length)
      end
      
      send_answers(answers, path[:of_scored])
    end
  end
end
