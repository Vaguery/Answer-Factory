module Machine::Nudge
  class RemoveAnyOne < Machine
    def defaults
      path[:of_remainder] = self
    end
    
    def process (answers)
      index = rand(answers.length)
      answers.delete_at(index)
      
      send_answers(answers, path[:of_remainder])
    end
  end
end
