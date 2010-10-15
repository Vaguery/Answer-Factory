# encoding: UTF-8
class SplitGroupWinners < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def group_size (n)
    @group_size = n
  end
  
  def maximum (n)
    @maximum = n
  end
  
  def process_answers
    @criteria ||= []
    @group_size ||= 10
    
    best = []
    rest = []
    
    answers.shuffle.each_slice(@group_size) do |group|
      group.each do |a|
        nondominated = true
        
        group.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        (nondominated ? best : rest) << a
      end
    end unless @group_size == 0
    
    if @maximum && best.length > @maximum
      rest.concat best.slice!(@maximum..-1)
    end
    
    return :best => best,
           :rest => rest
  end
end
