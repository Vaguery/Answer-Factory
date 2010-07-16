module Machine::Nudge
  class GenerateRandom < Machine
    paths :created
    
    options :number_created => 1,
            :nudge_writer => NudgeWriter.new
    
    def process (answers)
      created = (0...@number_created).collect do
        Answer.new(:blueprint => @nudge_writer.random, :language => 'nudge', :progress => 0)
      end
      
      return :created => created
    end
  end
end
