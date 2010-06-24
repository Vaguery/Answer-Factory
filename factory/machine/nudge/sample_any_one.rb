module Machine::Nudge
  class SampleAnyOne < Machine
    path :of_sampled_one,
         :of_rest
    
    def process (answers)
      return if answers.empty?
      
      index = rand(answers.length)
      sampled_answer = answers.delete_at(index)
      
      send_answer(sampled_answer, path[:of_sampled_one])
      send_answers(answers, path[:of_rest])
    end
  end
end
