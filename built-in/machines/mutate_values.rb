# encoding: UTF-8
class MutateValues < Machine
  def create (n)
    @number_to_create = n
  end
  
  def mutate (n)
    @values_to_mutate = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    @number_to_create ||= 1
    @values_to_mutate ||= 1
    @writer ||= Writer.new
    
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
    # progress = parent.progress + 1
      
      @number_to_create.times do
        new_blueprint = blueprint.mutate_n_values_at_random(@values_to_mutate, @writer)
        created << Answer.new(new_blueprint)
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
