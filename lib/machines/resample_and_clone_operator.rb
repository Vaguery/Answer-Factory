module AnswerFactory
  class ResampleAndCloneOperator < SearchOperator
  
    # returns an Array of clones of Answers randomly selected from the crowd passed in
    # 
    # the first (required) parameter is an Array of Answers
    # the second (optional) parameter is how many samples to take, and defaults to 1
    #
    # For example, if
    # <tt>@currentPopulation = [a list of 300 Answers]</tt> and
    # <tt>myRandomSampler = ResampleAndCloneOperator.new(@currentPopulation)</tt>
    # [<tt>myRandomSampler.generate()</tt>]
    #   produces a list of 1 Answer, which is a clone of somebody from <tt>@currentPopulation</tt>
    # [<tt>myRandomGuesser.generate(11)</tt>]
    #   returns a list of 11 Answers cloned from <tt>@currentPopulation</tt>,
    #   possibly including repeats
  
    def generate(crowd, howMany = 1)
      result = Batch.new
      howMany.times do
        donor = crowd.sample
        clone = Answer.new(donor.blueprint, progress:donor.progress + 1)
        result << clone
      end
      return result
    end
  end
end