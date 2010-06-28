module Machine::Nudge
  class MutatePoint < Machine
    option :number_of_mutants => 1,
           :nudge_writer => NudgeWriter.new
    
    path :of_mutated,
         :of_mutants,
         :of_unused
    
    def process (answers)
      return if answers.empty?
      
      mutated = answers.shuffle!.pop
      mutants = []
      
      @number_of_mutants.times do
        tree = NudgePoint.from(mutated.blueprint)
        
        n_of_mutation = rand(tree_points ||= tree.points)
        
        mutation = NudgePoint.from(@nudge_writer.random)
        
        if n_of_mutation == 0
          tree = mutation
        else
          tree.replace_point_at(n_of_mutation, mutation)
        end
        
        mutant = Answer.new(:blueprint => tree.to_script)
        
        mutants.push(mutant)
      end
      
      Factory::Log.answers(:create, mutants)
      
      send_answer(mutated, path[:of_mutated])
      send_answers(mutants, path[:of_mutants])
      send_answers(answers, path[:of_unused])
    end
  end
end
