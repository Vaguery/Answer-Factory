# encoding: UTF-8
class GenerateRandomAnswers < Machine
  def create (n)
    @number_to_create = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    @number_to_create ||= 1
    @writer ||= Writer.new
    
    created = []
    
    @number_to_create.times do
      created << Answer.new(@writer.random)
    end
    
    return :created => created
  end
end
