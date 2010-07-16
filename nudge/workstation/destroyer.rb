module Workstation::Nudge
  class Destroyer < Workstation
    attr_reader :destroy
    
    def setup
      @destroy = Machine::Nudge::Destroy.new(:destroy, self)
      
      schedule :destroy
    end
  end
end
