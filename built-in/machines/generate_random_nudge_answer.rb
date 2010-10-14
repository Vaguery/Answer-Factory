# encoding: UTF-8
class GenerateRandomNudgeAnswer < Machine
  def create (n)
    @number_to_create = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    @number_to_create ||= 1
    @writer ||= NudgeWriter.new
    
    created = (0...@number_to_create).collect do
      Answer.new(@writer.random, 'nudge')
    end
    
    return :created => created
  end
end
