# encoding: UTF-8
class SplitNondominated < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def process_answers
    @criteria ||= []
    
    best = []
    indices_of_best = []
    
    answers.shuffle!.each_with_index do |a, index|
      nondominated = true
      
      answers.each do |b|
        break unless nondominated &&= a.nondominated_vs?(b, @criteria)
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
