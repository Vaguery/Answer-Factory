require File.expand_path("../answer_factory", File.dirname(__FILE__))
require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'answer_factory')
require 'spec'

RSpec::Matchers.define :match_script do |other_script|
  match do |script|
    NudgePoint.from(script).to_script == NudgePoint.from(other_script).to_script
class FakeBlueprint < NudgeBlueprint
  def language
    :Fake
  end
  
  failure_message_for_should do |script|
    "expected #{script} to match #{other_script}"
  def blending_crossover (other)
    FakeBlueprint.new("-- fake -- ")
  end
  
  failure_message_for_should_not do |script|
    "expected #{script} to differ from #{other_script}"
  def delete_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  description do 
    "expected a Nudge script matching #{other_script}"
  def mutate_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
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