# encoding: UTF-8
module Machine::Nudge
  class ScoreProgress < Machine
    def process (answers)
      @score_name ||= :progress
      
      answers.each do |answer|
        answer.score(@score_name => -answer.progress)
      end
      
      return :scored => answers
    end
  end
end
