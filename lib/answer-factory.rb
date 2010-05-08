$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'
require 'configatron'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'machines/infrastructure'

require 'machines/all_duplicated_genomes_sampler'
require 'machines/any_one_sampler'
require 'machines/dominated_quantile_selector'
require 'machines/most_dominated_subset_sampler'
require 'machines/nondominated_subset_selector'
require 'machines/point_crossover_operator'
require 'machines/point_delete_operator'
require 'machines/point_mutation_operator'
require 'machines/program_point_count_evaluator'
require 'machines/random_guess_operator'
require 'machines/resample_and_clone_operator'
require 'machines/resample_values_operator'
require 'machines/test_case_evaluator'
require 'machines/uniform_backbone_crossover_operator'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
