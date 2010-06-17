module Machine::Nudge
  class GenerateRandom < Machine
    attr_accessor :number_of_points
    attr_accessor :number_of_answers
    
    def defaults
      @number_of_points = 10
      @number_of_answers = 1
      
      path[:to_recipient] = self
    end
    
    def process (answers)
      generated_answers = []
      
      @number_of_answers.times do
        random_script = ::Nudge.random(@number_of_points)
        generated_answers << Answer.new(:blueprint => random_script)
      end
      
      send_answers(generated_answers, path[:to_recipient])
    end
  end
end















class Nudge
  def Nudge.random (points)
    "block { #{"ref x1 " * (points - 1)}}"
  end
end
