# encoding: UTF-8
class DeleteRandomNudgePoint < Machine
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
    
    answers.each do |parent|
      blueprint = parent.blueprint
      
      @number_to_create.times do 
        tree = NudgePoint.from(blueprint)
        
        @points_to_delete.times do
          n_of_deletion = rand(tree.points)
          tree.delete_point_at(n_of_deletion) unless n_of_deletion == 0
        end
        
        created << Answer.new(tree.to_script, 'nudge')
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
