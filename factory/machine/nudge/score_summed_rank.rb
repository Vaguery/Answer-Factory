module Machine::Nudge
  class ScoreSummedRank < Machine
    options :criteria => {},
            :score_name => :summed_rank,
            :break_ties => false
    
    path :of_scored
    
    def process (answers)
      sum = Hash.new(0)
      rank_by = @criteria.keys
      score_1 = rank_by[0]
      score_2 = rank_by[1]
      
      answers.sort do |a,b|
        cmp = a.score(score_1) <=> b.score(score_1)
        
        if @break_ties && cmp == 0
          a.score(score_2) <=> b.score(score_2)
        else
          cmp
        end
      end.each_with_index do |a, i|
        sum[a.object_id] += i * (@criteria[score_1])
      end
      
      answers.sort do |a,b|
        cmp = a.score(score_2) <=> b.score(score_2)
        
        if @break_ties && cmp == 0
          a.score(score_1) <=> b.score(score_1)
        else
          cmp
        end
      end.each_with_index do |a, i|
        sum[a.object_id] += i * (@criteria[score_2])
      end
      
      answers.each do |a|
        a.score(@score_name, sum[a.object_id])
      end
      
      send_answers(answers, path[:of_scored])
    end
  end
end
