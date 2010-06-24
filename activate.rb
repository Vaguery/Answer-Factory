require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_of_answers = 256
  w.generate_random.path[:to_recipient] = :breeder, :sample_any_one
end

Workstation.new(:breeder) do |w|
  Machine::Nudge::SampleAnyOne.new(:sample_any_one, w) do |m|
    m.path[:of_sampled_one] = :breeder, :mutate_point
    m.path[:of_rest] = :breeder, :point_crossover
  end
  
  Machine::Nudge::MutatePoint.new(:mutate_point, w) do |m|
    m.number_of_mutants = 128
    m.path[:of_mutated] = :breeder, :point_crossover
    m.path[:of_mutants] = :breeder, :splitter
  end
  
  Machine.new(:splitter, w) do |m|
    m.path[:back] = :breeder, :mutate_point
    m.path[:forward] = :breeder, :point_crossover
    
    def m.process (answers)
      send_answers(answers.slice!(0...(answers.length / 2)), path[:back])
      send_answers(answers, path[:forward])
    end
  end
  
  Machine::Nudge::PointCrossover.new(:point_crossover, w) do |m|
    m.number_of_child_pairs = 64
    m.path[:of_parents] = :dead_parents
    m.path[:of_children] = :created_children
  end
  
  w.schedule :sample_any_one,
             [:mutate_point, "5x"],
             :splitter,
             [:point_crossover, "10x"]
end

Factory.schedule :generator, :breeder
Factory.run(5)
