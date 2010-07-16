module Machine::Nudge
  class ScoreSimpleError < Machine
    paths :scored
    
    options :score_name => :simple_error,
            :data_points => []
    
    def process (answers)
      answers.each do |answer|
        exe = Executable.new(answer.blueprint)
        scores = @data_points.collect {|data_point| score(exe, data_point) }
        
        avg = scores.inject(0.0) {|sum,n| sum + n } / scores.length
        
        answer.score(@score_name => avg)
      end
      
      return :scored => answers
    end
    
    def score (executable, data_point)
      0.0
    end
  end
end
