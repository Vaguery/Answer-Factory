module Machine::Nudge
  class DeletePoint < Machine
    paths :parents,
          :created
    
    options :number_created => 1
    
    def process (answers)
      created = []
      
      answers.each do |parent|
        blueprint = parent.blueprint
        progress = parent.progress + 1
        
        @number_created.times do
          tree = NudgePoint.from(blueprint)
          n_of_deletion = rand(tree_points ||= tree.points)
          
          tree.delete_point_at(n_of_deletion) unless n_of_deletion == 0
          
          created << Answer.new(:blueprint => tree.to_script, :language => 'nudge', :progress => progress)
        end
      end
      
      return :parents => answers,
             :created => created
    end
  end
end
