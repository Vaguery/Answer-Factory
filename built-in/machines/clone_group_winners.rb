# encoding: UTF-8
class CloneGroupWinners < Machine
  def criteria (*score_names)
    @criteria = score_names
  end
  
  def group_size (n)
    @group_size = n
  end
  
  def minimum (n)
    @minimum = n
  end
  
  def process_answers
    @criteria ||= []
    @group_size ||= 7
    @minimum ||= 1
    
    created = []
    
    while created.length < @minimum
      group = answers.sample(@group_size)
      
      group.each do |a|
        nondominated = true
        
        group.each do |b|
          break unless nondominated &&= a.nondominated_vs?(b, @criteria)
        end
        
        created << Answer.new(a.blueprint) if nondominated
      end
    end unless answers.empty? || @group_size == 0
    
    return :parents => answers,
           :created => created
  end
end
