# encoding: UTF-8
module Workstation::Nudge
  class Generator < Workstation
    attr_reader :generate_random
    
    def setup
      @generate_random = Machine::Nudge::GenerateRandom.new(:generate_random, self)
      
      schedule :generate_random
    end
  end
end
