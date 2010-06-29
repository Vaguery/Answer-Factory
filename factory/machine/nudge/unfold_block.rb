module Machine::Nudge
  class UnfoldBlock < Machine
    path :of_parents,
         :of_created,
         :of_unused
    
    def process (answers)
      parent = answers.shuffle!.pop
      tree = NudgePoint.from(parent.blueprint)
      
      if points = tree.instance_variable_get(:@points)
        blocks = []
        
        points.each_with_index do |point, i|
          blocks << [point, i] if point.is_a?(BlockPoint)
        end
        
        block, index = blocks.shuffle.first
        
        points[index..index] = block.instance_variable_get(:@points) if block
      end
      
      created = Answer.new(:blueprint => tree.to_script, :progress => parent.progress + 1)
      
      Factory::Log.answers(:create, [created])
      
      send_answer(parent, path[:of_parents])
      send_answer(created, path[:of_created])
      send_answers(answers, path[:of_unused])
    end
  end
end
