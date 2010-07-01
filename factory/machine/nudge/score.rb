module Machine::Nudge
  class Score < Machine
    options :data_points => []
    
    path :of_scored
    
    def process (answers)
      answers.each do |answer|
        exe = Executable.new(answer.blueprint)
        scores = @data_points.collect {|data_point| score(exe, data_point) }
        
        avg = scores.inject(0.0) {|sum,n| sum + n } / scores.length
        
        answer.score(:score, avg)
      end
      
      send_answers(answers, path[:of_scored])
    end
    
    def score (outcome)
      0.0
    end
  end
end
