module Machine::Nudge
  class GenerateRandom < Machine
    options :number_created => 1,
            :nudge_writer => NudgeWriter.new
    
    path :of_created
    
    def process (answers)
      created = (0...@number_created).collect { Answer.new(:blueprint => @nudge_writer.random, :progress => 0) }
      send_answers(created, path[:of_created])
    end
  end
end
