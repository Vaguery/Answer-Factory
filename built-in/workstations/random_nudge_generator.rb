# encoding: UTF-8
class RandomNudgeGenerator < Workstation
  def create (n)
    @machines[:generate_random].create(n)
  end
  
  def use_writer (writer)
    @machines[:generate_random].use_writer(writer)
  end
  
  def send (hash)
    @machines[:generate_random].send(:created => hash[:created])
  end
  
  def setup
    machine :generate_random, :GenerateRandomNudgeAnswer
  end
end
