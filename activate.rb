require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Writer = NudgeWriter.new do |writer|
    writer.value_types = [:int]
    writer.do_instructions = :int_add, :int_divide, :int_duplicate, :int_multiply,
                             :int_negative, :int_pop, :int_shove, :int_subtract,
                             :int_yank, :int_yankdup
end

Workstation::Nudge::Generator.new(:generator) do |generator|
  generator.generate_random.number_created = 10
  generator.generate_random.nudge_writer = Writer
  generator.generate_random.path[:of_created] = :breeder
end

Workstation.new(:breeder) do |breeder|
  Machine::Nudge::Split.new(:sample_any_one, breeder) do |sample_any_one|
    sample_any_one.best_n = 1
    sample_any_one.path[:of_best] = :breeder, :mutate_point
    sample_any_one.path[:of_rest] = :breeder, :point_crossover
  end
  
  Machine::Nudge::MutatePoint.new(:mutate_point, breeder) do |mutate_point|
    mutate_point.number_created = 10
    mutate_point.nudge_writer = Writer
    mutate_point.path[:of_parents] = :breeder, :point_crossover
    mutate_point.path[:of_created] = :breeder, :score_length
  end
  
  Machine::Nudge::PointCrossover.new(:point_crossover, breeder) do |point_crossover|
    point_crossover.number_of_pairs_created = 1
    point_crossover.path[:of_parents] = :breeder, :score_length
    point_crossover.path[:of_created] = :breeder, :score_length
  end
  
  Machine::Nudge::ScoreLength.new(:score_length, breeder) do |score_length|
    score_length.path[:of_scored] = :breeder, :split_by_length
  end
  
  Machine::Nudge::Split.new(:split_by_length, breeder) do |split|
    split.sort = :length
    split.split = 20, 80
    split.path[:of_best] = :breeder, :score_progress
    split.path[:of_rest] = :breeder, :mutate_point
  end
  
  Machine::Nudge::ScoreProgress.new(:score_progress, breeder) do |score_progress|
    score_progress.path[:of_scored] = :breeder, :split_by_progress
  end
  
  Machine::Nudge::Split.new(:split_by_progress, breeder) do |split|
    split.sort = :progress
    split.best_n = 1
    split.path[:of_best] = :best
    split.path[:of_rest] = :breeder, :point_crossover
  end
  
  breeder.schedule :sample_any_one,
                   [:mutate_point, "10x"],
                   :score_length,
                   :split_by_length,
                   [:point_crossover, "5x"],
                   :score_progress,
                   :split_by_progress
end

Factory.schedule :breeder
Factory.run(10)
