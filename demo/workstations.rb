# encoding: UTF-8
Factory::Log.disable = true

nudge_writer = NudgeWriter.new do |writer|
  writer.weight = {:block => 5, :do => 5, :ref => 1, :value => 2}
  writer.ref_names = %w:x:
  writer.value_types = [:int]
  writer.do_instructions = :int_abs,:int_add,:int_depth,:int_divide,:int_duplicate,:int_equal?,:int_flush,:int_greater_than?,:int_if,:int_less_than?,:int_max,:int_min,:int_modulo,:int_multiply,:int_negative,:int_pop,:int_rotate,:int_shove,:int_subtract,:int_swap,:int_yank,:int_yankdup
end

def f (x)
  (90 * x * x * x * x * x) - (135 * x * x * x * x) + (180 * x * x * x) - (225 * x * x) + (270 * x) - 315
end

data_points = [-100,-10,-3,-2,-1,0,1,2,4,7,11,32,61,112].collect  {|r| {:x => r, :y => f(r)}}

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_created = 10
  w.generate_random.nudge_writer = nudge_writer
  
  w.generate_random.path[:created] = :breeder
end

Workstation.new(:breeder) do |w|
  Machine::Nudge::PointCrossover.new(:point_crossover, w) do |m|
    m.pairs_created = 5
    
    m.path[:parents] = :breeder, :mutate_value
    m.path[:created] = :breeder, :split_unique
  end
  
  Machine::Nudge::MutateValue.new(:mutate_value, w) do |m|
    m.number_created = 1
    m.nudge_writer = nudge_writer
    
    m.path[:parents] = :breeder, :mutate_point
    m.path[:created] = :breeder, :split_unique
  end
  
  Machine::Nudge::MutatePoint.new(:mutate_point, w) do |m|
    m.nudge_writer = nudge_writer
    
    m.path[:parents] = :breeder, :unfold_block
    m.path[:created] = :breeder, :split_unique
  end
  
  Machine::Nudge::UnfoldBlock.new(:unfold_block, w) do |m|
    m.path[:parents] = :breeder, :delete_point
    m.path[:created] = :breeder, :delete_point
  end
  
  Machine::Nudge::DeletePoint.new(:delete_point, w) do |m|
    m.path[:parents] = :breeder, :fold_into_block
    m.path[:created] = :breeder, :fold_into_block
  end
  
  Machine::Nudge::FoldIntoBlock.new(:fold_into_block, w) do |m|
    m.path[:parents] = :breeder, :split_unique
    m.path[:created] = :breeder, :split_unique
  end
  
  Machine::Nudge::SplitUnique.new(:split_unique, w) do |m|
    m.path[:best] = :breeder, :score_length
    m.path[:rest] = :discard
  end
  
  Machine::Nudge::ScoreLength.new(:score_length, w) do |m|
    m.path[:scored] = :breeder, :score_simple_error
  end
  
  Machine::Nudge::ScoreSimpleError.new(:score_simple_error, w) do |m|
    m.data_points = data_points
    
    m.path[:scored] = :breeder, :split_nondominated
    
    def m.score (executable, data_point)
      outcome = executable.bind(:x => Value.new(:int, data_point[:x])).run
      return Factory::Infinity unless top_int = outcome.stacks[:int].last
      
      (data_point[:y] - top_int.to_i).abs
    end
  end
  
  Machine::Nudge::SplitNondominated.new(:split_nondominated, w) do |m|
    m.criteria = [:simple_error]
    
    m.path[:best] = :breeder
    m.path[:rest] = :discard
  end
  
  w.schedule :point_crossover,
             :mutate_value,
             :mutate_point,
             :unfold_block,
             :delete_point,
             :fold_into_block,
             :split_unique,
             :score_length,
             :score_simple_error,
             :split_nondominated
end