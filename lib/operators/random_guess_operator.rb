module AnswerFactory
  class RandomGuessOperator < SearchOperator
  
    # returns an Array of random Answers
    #
    # the first (optional) parameter specifies how many to make, and defaults to 1
    # the second (also optional) parameter is a hash that
    # can temporarily override those set in the initialization
    #
    # For example, if
    # <tt>myRandomGuesser = RandomGuessOperator.new(:randomIntegerLowerBound => -90000)</tt>
    #
    # [<tt>myRandomGuesser.generate()</tt>]
    #   produces a list of 1 Answer, and if it has any IntType samples they will be in [-90000,100]
    #   (since the default +:randomIntegerLowerBound+ is 100)
    # [<tt>myRandomGuesser.generate(1,:randomIntegerLowerBound => 0)</tt>]
    #   makes one Answer whose IntType samples (if any) will be between [0,100]
  
    def generate(crowd, overridden_options = {})
      every_option = @incoming_options.merge(overridden_options)
      how_many = every_option[:how_many] || 1
      how_many.times do
        newGenome = CodeType.any_value(every_option)
        newDude = Answer.new(newGenome, progress:0)
        crowd << newDude
      end
      return crowd
    end
  end
end