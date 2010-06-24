module Machine::Nudge
  class RemoveAnyOne < Machine
    path :of_remainder
    
    def process (answers)
      return if answers.empty?
      
      answers.shuffle!.pop
      
      send_answers(answers, path[:of_remainder])
    end
  end
end
