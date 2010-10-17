# encoding: UTF-8
class SplitNondominated < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def layers (n)
    @layers = n
  end
  
  def maximum (n)
    @maximum = n
  end
  
  def process_answers
    @criteria ||= []
    @layers ||= 1
    
    best = []
    rest = answers.shuffle
    
    @layers.times do
      indices_of_best = []
      
      rest.each_with_index do |a, index|
        nondominated = true
        
        answers.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        indices_of_best << index if nondominated
      end
      
      indices_of_best.reverse.each do |i|
        best << rest.delete_at(i)
      end
    end
    
    if @maximum && best.shuffle!.length > @maximum
      rest.concat best.slice!(@maximum..-1)
    end
    
    return :best => best,
           :rest => rest
  end
end
