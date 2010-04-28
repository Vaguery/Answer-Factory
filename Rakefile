require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "answer-factory"
    gemspec.summary = "Genetic Programming in the Nudge language"
    gemspec.description = "The pragmaticgp gem provides a simple framework for building, running and managing genetic programming experiments which automatically discover algorithms and equations to solve user-defined problems."
    gemspec.email = "bill@vagueinnovation.com"
    gemspec.homepage = "http://github.com/Vaguery/PragGP"
    gemspec.authors = ["Bill Tozier", "Trek Glowacki", "Jesse Sielaff"]
    
    gemspec.required_ruby_version = '>= 1.9.1'
    
    gemspec.add_dependency('nudge', '>= 0.2')
    gemspec.add_dependency('thor', '>= 0.13')
    gemspec.add_dependency('couchrest', '>= 0.33')
    gemspec.add_dependency('fakeweb', '>= 0.33')
    gemspec.add_dependency('sinatra', '>= 0.9.4')
    gemspec.add_dependency('activesupport', '>= 2.3.5')
    
    #files
    gemspec.files.include('templates/**')
    gemspec.files.exclude('_spikes/**')
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end