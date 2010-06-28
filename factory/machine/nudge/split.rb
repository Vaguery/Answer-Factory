module Machine::Nudge
  class Split < Machine
    options :sort => nil,
            :split => [50, 50],
            :best_n => nil
    
    path :of_best,
         :of_rest
    
    def process (answers)
      return if answers.empty?
      
      if @sort
        answers.sort! {|a,b| a.score(@sort) <=> b.score(@sort) }
      else
        answers.shuffle!
      end
      
      unless split_point = @best_n
        a = @split[0].to_f
        b = @split[1].to_f
        split_point = a / (a + b) * answers.length
      end
      
      best = answers.slice!(0...split_point)
      
      send_answers(best, path[:of_best])
      send_answers(answers, path[:of_rest])
    end
  end
end
