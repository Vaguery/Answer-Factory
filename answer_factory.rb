ANSWER_FACTORY_ROOT = '.' unless defined? ANSWER_FACTORY_ROOT
NUDGE_ROOT = "#{ANSWER_FACTORY_ROOT}/../Nudge" unless defined? NUDGE_ROOT

require "#{NUDGE_ROOT}/nudge"
require "#{ANSWER_FACTORY_ROOT}/factory/schedule"
require "#{ANSWER_FACTORY_ROOT}/factory/schedule/item"

Dir.glob("#{ANSWER_FACTORY_ROOT}/factory/*.rb") {|file| require file }
Dir.glob("#{ANSWER_FACTORY_ROOT}/factory/*/*.rb") {|file| require file }
Dir.glob("#{ANSWER_FACTORY_ROOT}/factory/*/*/*.rb") {|file| require file }
