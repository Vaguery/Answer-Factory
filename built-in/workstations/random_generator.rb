# encoding: UTF-8
class RandomGenerator < Workstation
  def create (n)
    @machines[:generate_random].create n
  end
  
  def use_writer (writer_class)
    @machines[:generate_random].use_writer writer_class
  end
  
  def send (hash)
    @machines[:generate_random].send created: hash[:created]
  end
  
  def setup
    machine :generate_random, :GenerateRandomAnswers
  end
end
