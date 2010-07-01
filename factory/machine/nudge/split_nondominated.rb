module Machine::Nudge
  class SplitNondominated < Machine
    options :criteria => []
    
    path :of_best,
         :of_rest
    
    def process (answers)
      best = []
      indices_of_best = []
      
      answers.each_with_index do |a, index|
        nondominated = true
        
        answers.each do |b|
          nondominated_vs_b = true
          
          criteria.each do |score_name|
            a_score = a.score(score_name)
            b_score = b.score(score_name)
            
            if a_score < b_score
              nondominated_vs_b = true
              break
            elsif nondominated_vs_b
              nondominated_vs_b &&= (a_score == b_score)
            end
          end
          
          break unless nondominated &&= nondominated_vs_b
        end
        
        indices_of_best << index if nondominated
      end
      
      indices_of_best.reverse.each do |i|
        best << answers.delete_at(i)
      end
      
      send_answers(best, path[:of_best])
      send_answers(answers, path[:of_rest])
    end
  end
end
