# encoding: UTF-8
class SplitWeighted < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def groups (n)
    @groups = n
  end
  
  def minimum (n)
    @minimum = n
  end
  
  def process_answers
    @criteria ||= []
    @groups ||= 7
    @minimum ||= 50
    
    group_size = (answers.length / @groups.to_f).ceil
    
    weighted = []
    
    while weighted.length < @minimum
      group = answers.sample(group_size)
      
      group.each do |a|
        nondominated = true
        
        group.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        weighted << Answer.new(a.blueprint, 'nudge') if nondominated
      end
    end unless group_size == 0
    
    return :weighted => weighted,
           :original => answers
  end
end
