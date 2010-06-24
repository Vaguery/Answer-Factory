require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_of_answers = 10
  w.generate_random.path[:to_recipient] = :breeder, :sample_any_one
end

Workstation.new(:breeder) do |w|
  Machine::Nudge::SampleAnyOne.new(:sample_any_one, w) do |m|
    m.path[:of_sampled_one] = :breeder, :mutate_point
    m.path[:of_rest] = :breeder, :point_crossover
  end
  
  Machine::Nudge::MutatePoint.new(:mutate_point, w) do |m|
    m.number_of_mutants = 10
    m.path[:of_mutated] = :breeder, :point_crossover
    m.path[:of_mutants] = :breeder, :splitter
  end
  
  Machine::Nudge::SplitThreeWays.new(:splitter, w) do |m|
    m.proportion = 20, 60, 20
    m.path[:low] = :breeder, :mutate_point
    m.path[:high] = :breeder, :point_crossover
  end
  
  Machine::Nudge::PointCrossover.new(:point_crossover, w) do |m|
    m.number_of_child_pairs = 10
    m.path[:of_parents] = :dead_parents
    m.path[:of_children] = :created_children
  end
  
  w.schedule :sample_any_one,
             [:mutate_point, "10x"],
             :splitter,
             [:point_crossover, "10x"]
end

Factory.schedule :generator, :breeder
Factory.run(10)
