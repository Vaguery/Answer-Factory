require '../Nudge/nudge'
require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_of_answers = 40
  w.generate_random.path[:to_recipient] = :shuffler, :sample_any_one
end

Workstation.new(:shuffler) do |w|
  Machine::Nudge::SampleAnyOne.new(:sample_any_one, w) do |m|
    m.path[:of_sampled_one] = :shuffler, :send_along
    m.path[:of_rest] = :shuffler, :point_crossover
  end
  
  Machine.new(:send_along, w) do |m|
    def m.process (answers)
      send_answers(answers, [:shuffler, :send_to_scrap])
    end
  end
  
  Machine::Nudge::PointCrossover.new(:point_crossover, w) do |m|
    m.number_of_child_pairs = 5
    m.path[:of_parents] = :dead_parents
    m.path[:of_children] = :created_children
  end
  
  Machine.new(:send_to_scrap, w) do |m|
    def m.process (answers)
      send_answers(answers, :scrapyard, :never_used)
    end
  end
  
  w.schedule :sample_any_one,
             :send_along,
             [:point_crossover, "10x"]
             :send_to_scrap
end

Factory.schedule :generator, :shuffler
Factory.run(5)
