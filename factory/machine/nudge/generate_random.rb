module Machine::Nudge
  class GenerateRandom < Machine
    options :number_of_answers => 1,
            :nudge_writer => NudgeWriter.new
    
    path :to_recipient
    
    def process (answers)
      generated_answers = (0...@number_of_answers).collect do
        Answer.new(:blueprint => @nudge_writer.random)
      end
      
      send_answers(generated_answers, path[:to_recipient])
    end
  end
end
