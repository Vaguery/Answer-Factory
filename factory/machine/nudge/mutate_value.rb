module Machine::Nudge
  class MutateValue < Machine
    option :number_created => 1,
           :nudge_writer => NudgeWriter.new
    
    path :of_parents,
         :of_created,
         :of_unused
    
    def process (answers)
      parent = answers.shuffle!.pop
      blueprint = parent.blueprint
      progress = parent.progress + 1
      
      created = []
      
      @number_created.times do
        tree = NudgePoint.from(blueprint)
        
        if value_type = tree.instance_variable_get(:@value_type)
          tree = NudgePoint.from(@nudge_writer.random_value(value_type))
        else
          value_point_indices = (1...tree.points).collect do |n|
            point = tree.get_point_at(n)
            [n, value_type] if value_type = point.instance_variable_get(:@value_type)
          end
          
          n, value_type = value_point_indices.compact.shuffle.first
          
          if n
            new_value_point = NudgePoint.from(@nudge_writer.random_value(value_type))
            tree.replace_point_at(n, new_value_point)
          end
        end
        
        created.push(Answer.new(:blueprint => tree.to_script, :progress => progress))
      end
      
      Factory::Log.answers(:create, created)
      
      send_answer(parent, path[:of_parents])
      send_answers(created, path[:of_created])
      send_answers(answers, path[:of_unused])
    end
  end
end
