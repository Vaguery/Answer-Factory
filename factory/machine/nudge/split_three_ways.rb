module Machine::Nudge
  class SplitThreeWays < Machine
    options :sort => nil,
            :proportion => [33, 33, 33]
    
    path :low,
         :mid,
         :high
    
    def process (answers)
      return if answers.empty?
      
      low = proportion[0].to_f
      mid = proportion[1].to_f
      high = proportion[2].to_f
      total = low + mid + high
      length = answers.length
      
      split_1 = low / (total) * length
      split_2 = (low + mid) / (total) * length
      
      unless sort
        answers.shuffle!
      end
      
      send_answers(answers[0...split_1], path[:low])
      send_answers(answers[split_1...split_2], path[:mid])
      send_answers(answers[split_2..-1], path[:high])
    end
  end
end
