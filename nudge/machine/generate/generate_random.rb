# encoding: UTF-8
module Machine::Nudge
  class GenerateRandom < Machine
    def process (answers)
      @number_created ||= 1
      @nudge_writer ||= NudgeWriter.new
      
      created = (0...@number_created).collect do
        Answer.new(@nudge_writer.random, 'nudge')
      end
      
      return :created => created
    end
  end
end
