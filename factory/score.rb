# encoding: UTF-8
class Score # :nodoc:
  # call-seq:
  #   Score.load (id: Integer, value: Float) -> score
  # 
  # Returns a new +Score+ instance with the given +id+ and +value+.
  # 
  #   Score.load(1, 1.5)      #=> #<Score:0x10012dbe8 @id=1 @value=1.5>
  # 
  def Score.load (id, value)
    score = Score.new(value)
    score.instance_variable_set(:@id, id.to_i)
    score
  end
  
  # call-seq:
  #   Score.new (value: Float) -> score
  # 
  # Returns a new +Score+ instance with the given +value+.
  # 
  #   Score.new(1.5)          #=> #<Score:0x10012dbe8 @value=1.5>
  # 
  def initialize (value)
    @value = value.to_f
  end
  
  # call-seq:
  #   score.id -> integer or nil
  # 
  # Returns +score+'s Integer id, or +nil+ if +score+ has no id.
  # 
  #   loaded_score = Score.load(1, 1.5)
  #   loaded_score.id         #=> 1
  #   
  #   new_score = Score.new(1.5)
  #   new_score.id            #=> nil
  # 
  def id
    @id
  end
  
  # call-seq:
  #   score.value -> float
  # 
  # Returns +score+'s Float value.
  # 
  #   score = Score.new(1.5)
  #   
  #   score.value             #=> 1.5
  # 
  def value
    @value
  end
  
  # call-seq:
  #   score.value= (float) -> float
  # 
  # Sets and returns +score+'s Float value.
  # 
  #   score = Score.load(1, 1.5)
  #   
  #   score.value             #=> 1.5
  #   score.value = 2.5       #=> 2.5
  #   score.value             #=> 2.5
  # 
  def value= (value)
    @value = value.to_f
  end
end
