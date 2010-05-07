$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'
require 'configatron'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'operators/infrastructure'

require 'operators/all_duplicated_genomes_sampler'
require 'operators/any_one_sampler'
require 'operators/dominated_quantile_selector'
require 'operators/most_dominated_subset_sampler'
require 'operators/nondominated_subset_selector'
require 'operators/point_crossover_operator'
require 'operators/point_delete_operator'
require 'operators/point_mutation_operator'
require 'operators/program_point_count_evaluator'
require 'operators/random_guess_operator'
require 'operators/resample_and_clone_operator'
require 'operators/resample_values_operator'
require 'operators/test_case_evaluator'
require 'operators/uniform_backbone_crossover_operator'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
