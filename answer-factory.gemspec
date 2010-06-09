# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{answer-factory}
  s.version = "0.1.3.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bill Tozier", "Trek Glowacki", "Jesse Sielaff"]
  s.date = %q{2010-06-09}
  s.default_executable = %q{answer-factory}
  s.description = %q{The pragmaticgp gem provides a simple framework for building, running and managing genetic programming experiments which automatically discover algorithms and equations to solve user-defined problems.}
  s.email = %q{bill@vagueinnovation.com}
  s.executables = ["answer-factory"]
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".gitignore",
     "LICENSE.txt",
     "Rakefile",
     "Thorfile",
     "VERSION",
     "_spikes/old_vs_new_dominated_by?.rb",
     "answer-factory.gemspec",
     "bin/answer-factory",
     "lib/answer-factory.rb",
     "lib/answers/answer.rb",
     "lib/answers/batch.rb",
     "lib/factories/factory.rb",
     "lib/factories/workstation.rb",
     "lib/machines/any_one.rb",
     "lib/machines/build_random.rb",
     "lib/machines/evaluate_simple_score.rb",
     "lib/machines/evaluate_with_test_cases.rb",
     "lib/machines/infrastructure.rb",
     "lib/machines/mutate_codeblock.rb",
     "lib/machines/mutate_footnotes.rb",
     "lib/machines/point_crossover.rb",
     "lib/machines/select_by_summed_rank.rb",
     "lib/machines/select_nondominated.rb",
     "readme.md",
     "spec/answers/answer_spec.rb",
     "spec/answers/batch_spec.rb",
     "spec/factories/factory_spec.rb",
     "spec/factories/workstation_spec.rb",
     "spec/fixtures/my_data_source.csv",
     "spec/integration_specs/couch_db_integration.rspec",
     "spec/machines/any_one_spec.rb",
     "spec/machines/build_random_spec.rb",
     "spec/machines/evaluate_simple_score_spec.rb",
     "spec/machines/evaluate_with_test_cases_spec.rb",
     "spec/machines/infrastructure_spec.rb",
     "spec/machines/mutate_codeblock_spec.rb",
     "spec/machines/mutate_footnotes_spec.rb",
     "spec/machines/point_crossover_spec.rb",
     "spec/machines/select_by_summed_rank_spec.rb",
     "spec/machines/select_nondominated_spec.rb",
     "spec/spec_helper.rb",
     "tasks/setup_factory.thor",
     "templates/answer_factory_activate_template.erb",
     "templates/answer_factory_spec_helper_template.erb"
  ]
  s.homepage = %q{http://github.com/Vaguery/PragGP}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Genetic Programming in the Nudge language}
  s.test_files = [
    "spec/answers/answer_spec.rb",
     "spec/answers/batch_spec.rb",
     "spec/factories/factory_spec.rb",
     "spec/factories/workstation_spec.rb",
     "spec/machines/any_one_spec.rb",
     "spec/machines/build_random_spec.rb",
     "spec/machines/evaluate_simple_score_spec.rb",
     "spec/machines/evaluate_with_test_cases_spec.rb",
     "spec/machines/infrastructure_spec.rb",
     "spec/machines/mutate_codeblock_spec.rb",
     "spec/machines/mutate_footnotes_spec.rb",
     "spec/machines/point_crossover_spec.rb",
     "spec/machines/select_by_summed_rank_spec.rb",
     "spec/machines/select_nondominated_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nudge>, [">= 0.2.9"])
      s.add_runtime_dependency(%q<thor>, [">= 0.13"])
      s.add_runtime_dependency(%q<couchrest>, [">= 0.33"])
      s.add_runtime_dependency(%q<configatron>, [">= 2.6.2"])
      s.add_runtime_dependency(%q<json_pure>, [">= 1.4.1"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
    else
      s.add_dependency(%q<nudge>, [">= 0.2.9"])
      s.add_dependency(%q<thor>, [">= 0.13"])
      s.add_dependency(%q<couchrest>, [">= 0.33"])
      s.add_dependency(%q<configatron>, [">= 2.6.2"])
      s.add_dependency(%q<json_pure>, [">= 1.4.1"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    end
  else
    s.add_dependency(%q<nudge>, [">= 0.2.9"])
    s.add_dependency(%q<thor>, [">= 0.13"])
    s.add_dependency(%q<couchrest>, [">= 0.33"])
    s.add_dependency(%q<configatron>, [">= 2.6.2"])
    s.add_dependency(%q<json_pure>, [">= 1.4.1"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
  end
end

