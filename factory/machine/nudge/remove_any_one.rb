module Machine::Nudge
  class RemoveAnyOne < Machine
    path :of_remainder
    
    def process (answers)
      return if answers.empty?
      
      index = rand(answers.length)
      answers.delete_at(index)
      
      send_answers(answers, path[:of_remainder])
    end
  end
end
