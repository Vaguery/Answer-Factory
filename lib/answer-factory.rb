$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'operators/infrastructure'
require 'operators/random_guess_operator'
require 'operators/resample_and_clone_operator'
require 'operators/resample_values_operator'
require 'operators/uniform_backbone_crossover_operator'
require 'operators/point_crossover_operator'
require 'operators/point_delete_operator'
require 'operators/point_mutation_operator'

require 'operators/test_case_evaluator'
require 'operators/program_point_count_evaluator'



require 'operators/samplers_and_selectors'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
