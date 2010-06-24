module Machine::Nudge
  class SampleAnyOne < Machine
    path :of_sampled_one,
         :of_rest
    
    def process (answers)
      return if answers.empty?
      
      sampled = answers.shuffle!.pop
      
      send_answer(sampled, path[:of_sampled_one])
      send_answers(answers, path[:of_rest])
    end
  end
end
