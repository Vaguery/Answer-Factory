# encoding: UTF-8
class WrapBlock < Machine
  def create (n)
    @number_to_create = n
  end
  
  def process_answers
    @number_to_create ||= 1
    
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
      
      @number_to_create.times do
        new_blueprint = blueprint.wrap_block
        created << Answer.new(new_blueprint)
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
