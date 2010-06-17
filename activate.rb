require 'answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Workstation::Nudge::Generator.new(:generator) do |w|
  w.generate_random.number_of_answers = 100
  w.generate_random.path[:to_recipient] = :shuffler, :sample_any_one
end

Workstation.new(:shuffler) do |w|
  Machine::Nudge::SampleAnyOne.new(:sample_any_one, w) do |m|
    m.path[:of_sampled_one] = :shuffler, :send_along
    m.path[:of_rest] = :shuffler, :keep_half
  end
  
  Machine.new(:send_along, w) do |m|
    def m.process (answers)
      send_answers(answers, [:shuffler, :send_to_scrap])
    end
  end
  
  Machine.new(:keep_half, w) do |m|
    def m.process (answers)
      midpoint = answers.length / 2
      send_answers(answers[0...midpoint], self)
      send_answers(answers[midpoint..-1], [:shuffler, :send_to_scrap])
    end
  end
  
  Machine.new(:send_to_scrap, w) do |m|
    def m.process (answers)
      send_answers(answers, :scrap_pile)
    end
  end
  
  w.schedule :sample_any_one,
             :send_along,
             :keep_half,
             :send_to_scrap
end

Factory.schedule :generator, :shuffler
Factory.run(5)
