# encoding: UTF-8
module Machine::Nudge
  class ScoreErrors < Machine
    def process (answers)
      @score_name ||= :errors
      
      answers.each do |answer|
        exe = NudgeExecutable.new(answer.blueprint).run
        answer.score(@score_name => exe.stacks[:error].length)
      end
      
      return :scored => answers
    end
  end
end
