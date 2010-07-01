nudge_writer = NudgeWriter.new do |writer|
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

Workstation::Nudge::Generator.new(:generator) do |generator|
  generator.generate_random.number_created = 50
  generator.generate_random.nudge_writer = nudge_writer
  generator.generate_random.path[:of_created] = :breeder
end

Workstation.new(:breeder) do |breeder|
  Machine::Nudge::PointCrossover.new(:crossover, breeder) do |crossover|
    crossover.number_of_pairs_created = 15
    crossover.path[:of_parents] = :breeder, :mutate_value
    crossover.path[:of_created] = :breeder, :split_unique
  end
  
  Machine::Nudge::MutateValue.new(:mutate_value, breeder) do |mutate|
    mutate.number_created = 30
    mutate.nudge_writer = nudge_writer
    mutate.path[:of_parents] = :breeder, :mutate
    mutate.path[:of_created] = :breeder, :split_unique
  end
  
  Machine::Nudge::MutatePoint.new(:mutate, breeder) do |mutate|
    mutate.nudge_writer = nudge_writer
    mutate.path[:of_parents] = :breeder, :unfold
    mutate.path[:of_created] = :breeder, :split_unique
  end
  
  Machine::Nudge::UnfoldBlock.new(:unfold, breeder) do |unfold|
    unfold.path[:of_parents] = :breeder, :delete
    unfold.path[:of_created] = :breeder, :delete
  end
  
  Machine::Nudge::DeletePoint.new(:delete, breeder) do |delete|
    delete.path[:of_parents] = :breeder, :fold
    delete.path[:of_created] = :breeder, :fold
  end
  
  Machine::Nudge::FoldIntoBlock.new(:fold, breeder) do |fold|
    fold.path[:of_parents] = :breeder, :split_unique
    fold.path[:of_created] = :breeder, :split_unique
  end
  
  Machine::Nudge::SplitUnique.new(:split_unique, breeder) do |split|
    split.path[:of_best] = :breeder, :score_length
    split.path[:of_rest] = :scrap
  end
  
  Machine::Nudge::ScoreLength.new(:score_length, breeder) do |score|
    score.path[:of_scored] = :breeder, :score_error
  end
  
  Machine::Nudge::Score.new(:score_error, breeder) do |score|
    score.data_points = data_points
    
    def score.score (executable, data_point)
      outcome = executable.bind(:x => Value.new(:int, data_point[:x])).run
      return 1/0.0 unless top_int = outcome.stacks[:int].last
      
      (data_point[:y] - top_int.to_i).abs
    end
    
    score.path[:of_scored] = :breeder, :nondominated
  end
  
  Machine::Nudge::SplitNondominated.new(:nondominated, breeder) do |split|
    split.criteria = :length, :score
    split.path[:of_best] = :breeder, :crossover
    split.path[:of_rest] = :scrap
  end
  
  breeder.schedule [:crossover, "100x"],
                   [:mutate_value, "100x"],
                   [:mutate, "100x"],
                   [:unfold, "100x"],
                   [:delete, "200x"],
                   [:fold, "400x"],
                   :split_unique,
                   :score_length,
                   :score_error,
                   :nondominated
end
