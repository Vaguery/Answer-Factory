# encoding: UTF-8
module Machine::Nudge
  class ScoreSimpleError < Machine
    def process (answers)
      @score_name ||= :simple_error
      @data_points ||= []
      
      answers.each do |answer|
        exe = NudgeExecutable.new(answer.blueprint)
        scores = @data_points.collect {|data_point| score(exe, data_point) }
        
        avg = scores.inject(0.0) {|sum,n| sum + n } / scores.length
        
        answer.score(@score_name => avg)
      end
      
      return :scored => answers
    end
    
    def score (executable, data_point)
      Factory::Infinity
    end
  end
end
