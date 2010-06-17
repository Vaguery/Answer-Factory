module Machine::Nudge
  class SampleAnyOne < Machine
    def defaults
      path[:of_sampled_one] = self
      path[:of_rest] = self
    end
    
    def process (answers)
      index = rand(answers.length)
      sampled_answer = answers.delete_at(index)
      
      send_answer(sampled_answer, path[:of_sampled_one])
      send_answers(answers, path[:of_rest])
    end
  end
end
