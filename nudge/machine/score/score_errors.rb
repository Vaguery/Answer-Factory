module Machine::Nudge
  class ScoreErrors < Machine
    paths :scored
    
    options :score_name => :errors
    
    def process (answers)
      answers.each do |answer|
        outcome = Executable.new(answer.blueprint).run
        answer.score(@score_name => outcome.stacks[:error].length)
      end
      
      return :scored => answers
    end
  end
end
