# encoding: UTF-8
class SplitNondominatedTournament < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def groups (n)
    @groups = n
  end
  
  def maximum (n)
    @maximum = n
  end
  
  def process_answers
    @criteria ||= []
    @groups ||= 4
    
    group_size = (answers.length / @groups.to_f).ceil
    
    best = []
    rest = []
    
    answers.shuffle.each_slice(group_size) do |group|
      group.each do |a|
        nondominated = true
        
        group.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        (nondominated ? best : rest) << a
      end
    end unless group_size == 0
    
    if @maximum && best.length > @maximum
      rest.concat best.slice!(@maximum..-1)
    end
    
    return :best => best,
           :rest => rest
  end
end
