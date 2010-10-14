# encoding: UTF-8
class Score
  def initialize (name, value, answer_id)
    @name = name.to_s
    @value = value.to_f
    @answer_id = answer_id.to_i
    
    if "".respond_to?(:force_encoding)
      @name.force_encoding("utf-8")
    end
  end
  
  def id
    @id
  end
  
  def name
    @name
  end
  
  def value
    @value
  end
  
  def answer_id
    @answer_id
  end
end
