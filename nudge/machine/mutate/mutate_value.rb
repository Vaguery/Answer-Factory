module Machine::Nudge
  class MutateValue < Machine
    paths :parents,
          :created
    
    options :number_created => 1,
            :nudge_writer => NudgeWriter.new
    
    def process (answers)
      created = []
      
      answers.each do |parent|
        blueprint = parent.blueprint
        progress = parent.progress + 1
        
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
          
          created << Answer.new(:blueprint => tree.to_script, :language => 'nudge', :progress => progress)
        end
      end
      
      return :parents => answers,
             :created => created
    end
  end
end
