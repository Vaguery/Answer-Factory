module AnswerFactory
  
  # Abstract class that from which specific SearchOperator subclasses inherit initialization
  
  class SearchOperator
    attr_accessor :incoming_options
    
     def initialize(options={})
       @incoming_options = options
     end
  end
  
  
  class Evaluator < SearchOperator
    attr_accessor :score_label
    
    def initialize(params = {})
      raise(ArgumentError, "Evaluators must have a score_label") if params[:score_label] == nil
      @score_label = params[:score_label]
    end
  end
  
end