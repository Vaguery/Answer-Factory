$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'
require 'configatron'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'machines/infrastructure'
require 'machines/any_one'
require 'machines/build_random'
require 'machines/evaluate_simple_score'
require 'machines/evaluate_with_test_cases'
require 'machines/select_nondominated'
require 'machines/mutate_footnotes'



require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
