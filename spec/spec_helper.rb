require File.expand_path("../answer_factory", File.dirname(__FILE__))
require 'rspec'

RSpec::Matchers.define :match_script do |other_script|
  match do |script|
    NudgePoint.from(script).to_script == NudgePoint.from(other_script).to_script
  end
  
  failure_message_for_should do |script|
    "expected #{script} to match #{other_script}"
  end
  
  failure_message_for_should_not do |script|
    "expected #{script} to differ from #{other_script}"
  end
  
  description do 
    "expected a Nudge script matching #{other_script}"
  end
end
