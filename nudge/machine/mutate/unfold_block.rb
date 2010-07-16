module Machine::Nudge
  class UnfoldBlock < Machine
    paths :parents,
          :created
    
    def process (answers)
      created = []
      
      answers.each do |parent|
        tree = NudgePoint.from(parent.blueprint)
        
        if points = tree.instance_variable_get(:@points)
          blocks = []
          
          points.each_with_index do |point, i|
            blocks << [point, i] if point.is_a?(BlockPoint)
          end
          
          block, index = blocks.shuffle.first
          
          points[index..index] = block.instance_variable_get(:@points) if block
        end
        
        created << Answer.new(:blueprint => tree.to_script, :language => 'nudge', :progress => parent.progress + 1)
      end
      
      return :parents => answers,
             :created => created
    end
  end
end
