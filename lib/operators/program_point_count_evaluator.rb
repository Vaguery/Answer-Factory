module AnswerFactory
  class ProgramPointEvaluator < Evaluator
    def evaluate(batch)
      raise(ArgumentError, "Can only evaluate a Batch of Answers") if !batch.kind_of?(Batch)
      batch.each do |i|
        if i.parses?
          i.scores[@score_label] = i.program.points
        else
          raise(ArgumentError, "Program is not parseable")
        end
      end
    end
  end
end