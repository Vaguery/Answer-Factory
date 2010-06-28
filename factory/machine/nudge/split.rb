module Machine::Nudge
  class Split < Machine
    options :sort => nil,
            :proportion => [50, 50],
            :top => nil
    
    path :low,
         :high
    
    def process (answers)
      return if answers.empty?
      
      if @sort
        answers.sort! do |a, b|
          a, b = @sort.call(a, b)
          a <=> b
        end
      else
        answers.shuffle!
      end
      
      if @top
        low = answers.slice!(0...-@top)
        high = answers
      else
        a = @proportion[0].to_f
        b = @proportion[1].to_f
        split_point = a / (a + b) * answers.length
        
        low = answers[0...split_point]
        high = answers[split_point...-1]
      end
      
      send_answers(low, path[:low])
      send_answers(high, path[:high])
    end
  end
end
