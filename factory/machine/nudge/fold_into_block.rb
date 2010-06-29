module Machine::Nudge
  class FoldIntoBlock < Machine
    path :of_parents,
         :of_created,
         :of_unused
    
    def process (answers)
      parent = answers.shuffle!.pop
      tree = NudgePoint.from(parent.blueprint)
      
      if points = tree.instance_variable_get(:@points)
        block_start, block_end = [rand(points.length), rand(points.length)].sort
        
        unless block_start == block_end
          block = BlockPoint.new(*points.slice!(block_start..block_end))
          points[block_start...block_start] = block
        end
      end
      
      created = Answer.new(:blueprint => tree.to_script, :progress => parent.progress + 1)
      
      Factory::Log.answers(:create, [created])
      
      send_answer(parent, path[:of_parents])
      send_answer(created, path[:of_created])
      send_answers(answers, path[:of_unused])
    end
  end
end
