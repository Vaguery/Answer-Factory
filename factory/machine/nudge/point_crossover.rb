module Machine::Nudge
  class PointCrossover < Machine
    def defaults
      path[:of_parents] = self
      path[:of_children] = self
      path[:of_unused] = self
    end
    
    def process (answers)
      if answers.length > 1
        a, b = answers.shuffle!.pop(2)
        
        tree_a = NudgePoint.from(a.blueprint)
        tree_b = NudgePoint.from(b.blueprint)
        
        n_of_a = rand(tree_a.points)
        n_of_b = rand(tree_b.points)
        
        if n_of_a > 0 && n_of_b > 0 # temporary
          point_a = tree_a.get_point_at(n_of_a)
          point_b = tree_b.replace_point_at(n_of_b, point_a)
          tree_a.replace_point_at(n_of_a, point_b)
          
          blueprint_c = tree_a.to_script
          blueprint_d = tree_b.to_script
          
          c = Answer.new(:blueprint => blueprint_c)
          d = Answer.new(:blueprint => blueprint_d)
          
          send_answers([a,b], path[:of_parents])
          send_answers([c,d], path[:of_children])
        end
      end
      
      send_answers(answers, path[:of_unused])
    end
  end
end
