module Machine::Nudge
  class DeletePoint < Machine
    option :number_created => 1
    
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
        n_of_deletion = rand(tree_points ||= tree.points)
        
        tree.delete_point_at(n_of_deletion) unless n_of_deletion == 0
        
        created.push(Answer.new(:blueprint => tree.to_script, :progress => progress))
      end
      
      Factory::Log.answers(:create, created)
      
      send_answer(parent, path[:of_parents])
      send_answers(created, path[:of_created])
      send_answers(answers, path[:of_unused])
    end
  end
end
