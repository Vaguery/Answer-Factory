# encoding: UTF-8
class FoldNudgeBlock < Machine
  def process_answers
    created = []
    
    answers.each do |parent|
      tree = NudgePoint.from(parent.blueprint)
      
      if points = tree.instance_variable_get(:@points)
        block_start, block_end = [rand(points.length), rand(points.length)].sort
        
        unless block_start == block_end
          block = BlockPoint.new(*points.slice!(block_start..block_end))
          points[block_start...block_start] = block
        end
      end
      
      created << Answer.new(tree.to_script, 'nudge')
    end
    
    return :parents => answers,
           :created => created
  end
end
