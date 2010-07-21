module Machine::Nudge
  class MutatePoint < Machine
    def process (answers)
      @number_created ||= 1
      @nudge_writer ||= NudgeWriter.new
      
      created = []
      
      answers.each do |parent|
        blueprint = parent.blueprint
        progress = parent.progress + 1
        
        @number_created.times do
          tree = NudgePoint.from(blueprint)
          
          n_of_mutation = rand(tree_points ||= tree.points)
          
          mutation = NudgePoint.from(@nudge_writer.random)
          
          if n_of_mutation == 0
            tree = mutation
          else
            tree.replace_point_at(n_of_mutation, mutation)
          end
          
          created << Answer.new(tree.to_script, 'nudge', progress)
        end
      end
      
      return :parents => answers,
             :created => created
    end
  end
end
