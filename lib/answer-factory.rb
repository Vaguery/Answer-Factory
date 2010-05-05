$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'operators/infrastructure'
require 'operators/random_guess_operator'
require 'operators/resample_and_clone_operator'
require 'operators/basic_operators'

require 'operators/samplers_and_selectors'
require 'operators/evaluators'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
