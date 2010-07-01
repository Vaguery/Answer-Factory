module Machine::Nudge
  class SplitUnique < Machine
    path :of_best,
         :of_rest
    
    def process (answers)
      unique = []
      indices_of_unique = []
      
      answers.each_with_index do |a, index|
        matched = false
        blueprint = a.blueprint
        
        unique.each do |b|
          if blueprint == b.blueprint
            matched = true
            break
          end
        end
        
        unless matched
          unique << a
          indices_of_unique << index
        end
      end
      
      indices_of_unique.reverse.each do |i|
        answers.delete_at(i)
      end
      
      send_answers(unique, path[:of_best])
      send_answers(answers, path[:of_rest])
    end
  end
end
