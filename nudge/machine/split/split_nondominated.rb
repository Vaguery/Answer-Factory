# encoding: UTF-8
module Machine::Nudge
  class SplitNondominated < Machine
    def process (answers)
      @criteria ||= []
      
      best = []
      indices_of_best = []
      
      answers.each_with_index do |a, index|
        nondominated = true
        
        answers.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b)
        end
        
        indices_of_best << index if nondominated
      end
      
      indices_of_best.reverse.each do |i|
        best << answers.delete_at(i)
      end
      
      return :best => best,
             :rest => answers
    end
  end
end
