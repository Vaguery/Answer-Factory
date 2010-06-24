module Machine::Nudge
  class SplitTwoWays < Machine
    options :sort => nil,
            :proportion => [50, 50]
    
    path :low,
         :high
    
    def process (answers)
      return if answers.empty?
      
      low = proportion[0].to_f
      high = proportion[1].to_f
      split_point = low / (low + high) * answers.length
      
      unless sort
        answers.shuffle!
      end
      
      send_answers(answers[0...split_point], path[:low])
      send_answers(answers[split_point..-1], path[:high])
    end
  end
end
