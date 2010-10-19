require File.join(File.dirname(__FILE__), '..', 'answer_factory')
require 'spec'

class FakeBlueprint < NudgeBlueprint
  def language
    :Fake
  end
  
  def blending_crossover (other)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def delete_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_values_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def point_crossover (other)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def unwrap_block
    FakeBlueprint.new("-- fake -- ")
  end
  
  def wrap_block
    FakeBlueprint.new("-- fake -- ")
  end
end