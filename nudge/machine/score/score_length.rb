module Machine::Nudge
  class ScoreLength < Machine
    def process (answers)
      @score_name ||= :length
      
      answers.each do |answer|
        answer.score(@score_name => answer.blueprint.length)
      end
      
      return :scored => answers
    end
  end
end
