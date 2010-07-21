module Machine::Nudge
  class SplitScore < Machine
    def process (answers)
      @split ||= [50, 50]
      
      if @score_name
        answers.sort! {|a,b| a.score(@score_name) <=> b.score(@score_name) }
      else
        answers.shuffle!
      end
      
      unless split_point = @best_n
        a = @split[0].to_f
        b = @split[1].to_f
        split_point = a / (a + b) * answers.length
      end
      
      best = answers.slice!(0...split_point)
      
      return :best => best,
             :rest => answers
    end
  end
end
