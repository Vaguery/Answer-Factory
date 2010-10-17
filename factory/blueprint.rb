# encoding: UTF-8
class Blueprint < String
  def language
    :""
  end
  
  def blending_crossover (other)
    self
  end
  
  def delete_n_points_at_random (n)
    self
  end
  
  def mutate_n_points_at_random (n)
    self
  end
  
  def mutate_n_values_at_random (n)
    self
  end
  
  def point_crossover (other)
    self
  end
  
  def unwrap_block
    self
  end
  
  def wrap_block
    self
  end
end
