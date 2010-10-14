# encoding: UTF-8
class DoNudgePointCrossover < Machine
  def create_pairs (n)
    @pairs_to_create = n
  end
  
  def process_answers
    @pairs_to_create ||= 1
    
    created = []
    
    answers.shuffle!.each_slice(2) do |a, b|
      b = a unless b
    # progress = [a.progress, b.progress].max + 1
      
      blueprint_a = a.blueprint
      blueprint_b = b.blueprint
      
      @pairs_to_create.times do
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
        
        c = Answer.new(tree_a.to_script, 'nudge')
        d = Answer.new(tree_b.to_script, 'nudge')
        
        created.concat [c, d]
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
