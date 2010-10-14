# encoding: UTF-8
class MutateNudgeValue < Machine
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
        
        if value_type = tree.instance_variable_get(:@value_type)
          tree = NudgePoint.from(@writer.random_value(value_type))
        else
          value_point_indices = (1...tree.points).collect do |n|
            point = tree.get_point_at(n)
            [n, value_type] if value_type = point.instance_variable_get(:@value_type)
          end
          
          n, value_type = value_point_indices.compact.shuffle.first
          
          if n
            new_value_point = NudgePoint.from(@writer.random_value(value_type))
            tree.replace_point_at(n, new_value_point)
          end
        end
        
        created << Answer.new(tree.to_script, 'nudge')
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
