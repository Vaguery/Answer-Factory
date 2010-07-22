# encoding: UTF-8
class Answer
  # call-seq:
  #   Answer.new (blueprint: String, language: String) -> answer
  # 
  # Returns a new +Answer+ instance with the given +blueprint+ and +language+.
  # 
  #   Answer.new("ref x", "nudge")  #=> #<Answer:0x10012dbe8
  #                                       @blueprint="ref x"
  #                                       @language="nudge"
  #                                       @progress=0
  #                                       @scores={}>
  # 
  def initialize (blueprint, language, progress = 0)
    @blueprint = blueprint.to_s
    @language = language.to_s
    @progress = progress.to_i
    @scores = {}
    
    if "".respond_to?(:force_encoding)
      @blueprint.force_encoding("utf-8")
      @language.force_encoding("utf-8")
    end
  end
  
  # call-seq:
  #   answer.blueprint -> string
  # 
  # Returns +answer+'s String blueprint.
  # 
  #   answer = Answer.new("ref x", "nudge")
  #   
  #   answer.blueprint        #=> "ref x"
  # 
  def blueprint
    @blueprint
  end
  
  # call-seq:
  #   answer.language -> string
  # 
  # Returns +answer+'s String language.
  # 
  #   answer = Answer.new("ref x", "nudge")
  #   
  #   answer.language         #=> "nudge"
  # 
  def language
    @language
  end
  
  # call-seq:
  #   answer.progress -> string
  # 
  # Returns +answer+'s Integer progress.
  # 
  #   answer = Answer.new("ref x", "nudge")
  #   
  #   answer.progress         #=> 0
  # 
  def progress
    @progress
  end
  
  # call-seq:
  #   answer.score (name: Symbol or {name: Symbol => value, * }) -> value or {name: Symbol => value, * }
  # 
  # Given a hash argument, associates the score names with new +Score+
  # instances containing the associated values, then returns the hash.
  # 
  #   answer = Answer.new("ref x", "nudge")
  #   
  #   answer.score(:x => 5)   #=> {:x=>5}
  # 
  # Given a symbol argument, returns the value of the named score in
  # +answer+'s scores hash.
  # 
  #   answer.score(:x)        #=> 5.0
  # 
  # If no answer exists with the given name, returns Factory::Infinity.
  # 
  #   answer.score(:y)        #=> 3.0e+38
  # 
  def score (arg)
    if arg.is_a? Symbol
      score = (@scores[arg] ||= Score.new(Factory::Infinity))
      return score.value
    end
    
    arg.each do |name, value|
      if score = @scores[name.to_sym]
        score.value = value
      else
        @scores[name.to_sym] = Score.new(value)
      end
    end
  end
  
  # 
  # 
  # 
  def Answer.load (id, blueprint, language, progress) # :nodoc:
    answer = Answer.new(blueprint, language, progress)
    answer.instance_variable_set(:@id, id.to_i)
    answer
  end
  
  # 
  # 
  # 
  def id # :nodoc:
    @id
  end
  
  # 
  # 
  # 
  def assign (workstation_name, machine_name) # :nodoc:
    @workstation = workstation_name
    @machine = machine_name
  end
  
  # 
  # 
  # 
  def workstation # :nodoc:
    @workstation
  end
  
  # 
  # 
  # 
  def machine # :nodoc:
    @machine
  end
end
