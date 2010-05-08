$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'rubygems'
require 'nudge'
require 'configatron'

require 'couchrest'

require 'answers/answer'
require 'answers/batch'

require 'machines/infrastructure'
require 'machines/sample_any_one'

require 'factories/factory'
require 'factories/workstation'

def AnswerFactory.gem_root
  File.dirname(__FILE__) + '/..'
end
