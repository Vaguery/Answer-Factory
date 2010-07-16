Factory::Log.stream = true

nudge_writer = NudgeWriter.new do |writer|
  writer.weight = {:block => 5, :do => 5, :ref => 1, :value => 2}
  writer.ref_names = %w:x:
  writer.value_types = [:int]
  writer.do_instructions = :int_add, :int_subtract, :int_multiply
end

def f (x)
  x + 6
end

data_points = {:x => -1000, :y => f(-1000)},
              {:x => -100, :y => f(-100)},
              {:x => -10, :y => f(-10)},
              {:x => -1, :y => f(-1)},
              {:x => 0, :y => f(0)},
              {:x => 1, :y => f(1)},
              {:x => 2, :y => f(2)},
              {:x => 3, :y => f(3)},
              {:x => 4, :y => f(4)},
              {:x => 10, :y => f(10)},
              {:x => 100, :y => f(100)},
              {:x => 1000, :y => f(1000)}

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
    m.number_created = 20
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
    m.path[:rest] = :destroyer
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
    m.criteria = :length, :simple_error
    
    m.path[:best] = :breeder
    m.path[:rest] = :breeder, :split_score
  end
  
  Machine::Nudge::SplitScore.new(:split_score, w) do |m|
    m.score_name = :simple_error
    m.best_n = 20
    
    m.path[:best] = :breeder
    m.path[:rest] = :reshuffler
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
             :split_nondominated,
             :split_score
end

Workstation.new(:reshuffler) do |w|
  Machine.new(:split_infinite_scores, w) do |m|
    m.path[:best] = :reshuffler, :split_score
    m.path[:rest] = :destroyer
    
    def m.process (answers)
      infinite, finite = answers.partition {|answer| answer.score(:simple_error) == Factory::Infinity }
      
      return :best => finite,
             :rest => infinite
    end
  end
  
  Machine::Nudge::SplitScore.new(:split_score, w) do |m|
    m.score_name = :simple_error
    m.best_n = 100
    
    m.path[:best] = :breeder
    m.path[:rest] = :reshuffler
  end
  
  w.schedule :split_infinite_scores,
             :split_score
end

Workstation::Nudge::Destroyer.new(:destroyer)
