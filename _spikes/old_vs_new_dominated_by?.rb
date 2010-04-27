require 'nudge'
require '../lib/answer-factory'
include Nudge
include NudgeGP


d1 = Answer.new("")
d2 = Answer.new("")

t1 = Time.now
100000.times do
  d1.scores = {"a" => rand(20)-10, "b" => rand(20)-10,"c" => rand(20)-10,"d" => rand(20)-10,"e" => rand(20)-10,"e1" => rand(20)-10,"e2" => rand(20)-10,"e3" => rand(20)-10,"e4" => rand(20)-10,"e5" => rand(20)-10,"e6" => rand(20)-10,"edfsgdf" => rand(20)-10,"se" => rand(20)-10}
  d2.scores =  {"a" => rand(20)-10, "b" => rand(20)-10,"c" => rand(20)-10,"d" => rand(20)-10,"e" => rand(20)-10,"e1" => rand(20)-10,"e2" => rand(20)-10,"e3" => rand(20)-10,"e4" => rand(20)-10,"e5" => rand(20)-10,"e6" => rand(20)-10,"edfsgdf" => rand(20)-10,"se" => rand(20)-10}
  d1.dominated_by?(d2)
end
puts "#{Time.now - t1} sec from the new one"


class Answer
  def dominated_by?(other, template = self.known_criteria)
    return false unless (known_criteria == other.known_criteria)
    
    noWorse = true
    somewhatBetter = false
    template.each do |score|
      if self.scores[score] && other.scores[score]
        noWorse &&= (self.scores[score] >= other.scores[score])
        somewhatBetter ||= (self.scores[score] > other.scores[score])
      else
        return false
      end
    end
    return noWorse && somewhatBetter
  end
end


t1 = Time.now
100000.times do
  d1.scores =  {"a" => rand(20)-10, "b" => rand(20)-10,"c" => rand(20)-10,"d" => rand(20)-10,"e" => rand(20)-10,"e1" => rand(20)-10,"e2" => rand(20)-10,"e3" => rand(20)-10,"e4" => rand(20)-10,"e5" => rand(20)-10,"e6" => rand(20)-10,"edfsgdf" => rand(20)-10,"se" => rand(20)-10}
  d2.scores =  {"a" => rand(20)-10, "b" => rand(20)-10,"c" => rand(20)-10,"d" => rand(20)-10,"e" => rand(20)-10,"e1" => rand(20)-10,"e2" => rand(20)-10,"e3" => rand(20)-10,"e4" => rand(20)-10,"e5" => rand(20)-10,"e6" => rand(20)-10,"edfsgdf" => rand(20)-10,"se" => rand(20)-10}
  d1.dominated_by?(d2)
end
puts "#{Time.now - t1} sec from the old one"

