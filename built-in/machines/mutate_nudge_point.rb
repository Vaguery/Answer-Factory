# encoding: UTF-8
class MutateNudgePoint < Machine
  def create (n)
    @number_to_create = n
  end
  
  def use_writer (writer_class)
    @writer = writer_class.new
  end
  
  def process_answers
    @number_to_create ||= 1
    @writer ||= NudgeWriter.new
    
    created = []
    
    answers.each do |parent|
      blueprint = parent.blueprint
    # progress = parent.progress + 1
      
      @number_to_create.times do
        tree = NudgePoint.from(blueprint)
        
        n_of_mutation = rand(tree_points ||= tree.points)
        
        mutation = NudgePoint.from(@writer.random)
        
        if n_of_mutation == 0
          tree = mutation
        else
          tree.replace_point_at(n_of_mutation, mutation)
        end
        
        created << Answer.new(tree.to_script, 'nudge')
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
