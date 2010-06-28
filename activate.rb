require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_of_answers = 10
  w.generate_random.path[:to_recipient] = :breeder, :sample_any_one
end

Workstation.new(:breeder) do |w|
  Machine::Nudge::Split.new(:sample_any_one, w) do |m|
    m.top = 1
    m.path[:low] = :breeder, :point_crossover
    m.path[:high] = :breeder, :mutate_point
  end
  
  Machine::Nudge::MutatePoint.new(:mutate_point, w) do |m|
    m.number_of_mutants = 10
    m.path[:of_mutated] = :breeder, :point_crossover
    m.path[:of_mutants] = :breeder, :split_by_length
  end
  
  Machine::Nudge::Split.new(:split_by_length, w) do |m|
    m.sort = proc do |a, b|
      return a.blueprint.length, b.blueprint.length
    end
    
    m.proportion = 80, 20
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
             :split_by_length,
             [:point_crossover, "10x"]
end

Factory.schedule :generator, :breeder
Factory.run(10)
