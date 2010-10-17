# encoding: UTF-8
class DoPointCrossover < Machine
  def create (n)
    @pairs_to_create = (n.to_f / 2).ceil
  end
  
  def process_answers
    @pairs_to_create ||= 1
    
    created = []
    
    answers_keyed_by_language.each do |language, group|
      group.shuffle!.each_slice(2) do |a, b|
        b = a unless b
      # progress = [a.progress, b.progress].max + 1
        
        blueprint_a = a.blueprint
        blueprint_b = b.blueprint
        
        @pairs_to_create.times do
          blueprint_c, blueprint_d = blueprint_a.point_crossover(blueprint_b)
          created.concat [Answer.new(blueprint_c), Answer.new(blueprint_d)]
        end
      end
    end
    
    return :parents => answers,
           :created => created
  end
end
