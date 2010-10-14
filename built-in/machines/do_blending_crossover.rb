# encoding: UTF-8
class DoBlendingCrossover < Machine
  def create (n)
    @number_to_create = n
  end
  
  def process_answers
    @number_to_create ||= 1
    
    created = []
    
    answers.shuffle!.each_slice(2) do |a, b|
      b = a unless b
    # progress = [a.progress, b.progress].max + 1
      
      tree_a = NudgePoint.from(a.blueprint)
      tree_b = NudgePoint.from(b.blueprint)
      
      a_top_level_points = tree_a.is_a?(BlockPoint) ? tree_a.instance_variable_get(:@points) : [tree_a]
      b_top_level_points = tree_b.is_a?(BlockPoint) ? tree_b.instance_variable_get(:@points) : [tree_b]
      
      available_points = a_top_level_points + b_top_level_points
      n = available_points.length
      
      @number_to_create.times do
        points = []
        
        (rand(n) + 1).times do
          points << available_points.sample
        end if n > 0
        
        blueprint = BlockPoint.new(*points).to_script
        
        created << Answer.new(blueprint, 'nudge')
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
