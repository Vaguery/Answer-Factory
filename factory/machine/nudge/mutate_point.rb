module Machine::Nudge
  class MutatePoint < Machine
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
        
        n_of_mutation = rand(tree_points ||= tree.points)
        
        mutation = NudgePoint.from(@nudge_writer.random)
        
        if n_of_mutation == 0
          tree = mutation
        else
          tree.replace_point_at(n_of_mutation, mutation)
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
