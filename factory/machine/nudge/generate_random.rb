module Machine::Nudge
  class GenerateRandom < Machine
    options :number_of_points => 10,
            :number_of_answers => 1
    
    path :to_recipient
    
    def process (answers)
      generated_answers = []
      
      @number_of_answers.times do
        random_script = ::Nudge.random(5 + rand(@number_of_points))
        generated_answers << Answer.new(:blueprint => random_script)
      end
      
      send_answers(generated_answers, path[:to_recipient])
    end
  end
end















class Nudge
  def Nudge.random (points)
    "block { block { ref a } block { ref b ref c } block { ref d block { ref e ref f } } ref g }"
  end
end
