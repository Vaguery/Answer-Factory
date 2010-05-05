module AnswerFactory
  
  # Abstract class that from which specific SearchOperator subclasses inherit initialization
  
  class SearchOperator
    attr_accessor :incoming_options
    
     def initialize(options={})
       @incoming_options = options
     end
  end
end