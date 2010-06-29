module Machine::Nudge
  class PointCrossover < Machine
    option :number_of_pairs_created => 1
    
    path :of_parents,
         :of_created,
         :of_unused
    
    def process (answers)
      a, b = parents =
        answers.length > 1 ?
        answers.shuffle!.pop(2) :
        [answers.pop] * 2
      
      blueprint_a = a.blueprint
      blueprint_b = b.blueprint
      progress = [a.progress, b.progress].max + 1
      
      created = []
      
      @number_of_pairs_created.times do
        tree_a = NudgePoint.from(blueprint_a)
        tree_b = NudgePoint.from(blueprint_b)
        
        n_of_a = rand(a_points ||= tree_a.points)
        n_of_b = rand(b_points ||= tree_b.points)
        
        if n_of_a != 0 && n_of_b != 0
          point_a = tree_a.get_point_at(n_of_a)
          point_b = tree_b.replace_point_at(n_of_b, point_a)
          tree_a.replace_point_at(n_of_a, point_b)
        elsif n_of_a == 0 && n_of_b != 0
          tree_a = tree_b.replace_point_at(n_of_b, tree_a)
        elsif n_of_a != 0 && n_of_b == 0
          tree_b = tree_a.replace_point_at(n_of_a, tree_b)
        end
        
        c = Answer.new(:blueprint => tree_a.to_script, :progress => progress)
        d = Answer.new(:blueprint => tree_b.to_script, :progress => progress)
        
        created.push(c, d)
      end
      
      Factory::Log.answers(:create, created)
      
      send_answers(parents, path[:of_parents])
      send_answers(created, path[:of_created])
      send_answers(answers, path[:of_unused])
    end
  end
end
