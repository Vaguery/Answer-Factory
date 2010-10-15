# encoding: UTF-8
class DoRandomDeletion < Machine
  def create (n)
    @number_to_create = n
  end
  
  def delete (n)
    @points_to_delete = n
  end
  
  def process_answers
    @number_to_create ||= 1
    @points_to_delete ||= 1
    
    created = []
    
    answers.each do |answer|
      blueprint = answer.blueprint
    # progress = parent.progress + 1
      
      @number_to_create.times do
        new_blueprint = blueprint.delete_n_points_at_random(@points_to_delete)
        created << Answer.new(new_blueprint)
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
