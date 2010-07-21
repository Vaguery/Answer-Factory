module Machine::Nudge
  class ScoreErrors < Machine
    def process (answers)
      @score_name ||= :errors
      
      answers.each do |answer|
        outcome = Executable.new(answer.blueprint).run
        answer.score(@score_name => outcome.stacks[:error].length)
      end
      
      return :scored => answers
    end
  end
end
