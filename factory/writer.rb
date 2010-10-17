# encoding: UTF-8
class Writer
  def initialize
    setup
  end
  
  def setup
  end
  
  def language
    :""
  end
  
  def random
    Blueprint.new
  end
  
  def random_value
    ""
  end
end
