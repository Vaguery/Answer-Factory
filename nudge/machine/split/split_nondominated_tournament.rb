# encoding: UTF-8
module Machine::Nudge
  class SplitNondominatedTournament < Machine
    def process (answers)
      @criteria ||= []
      @groups ||= 4
      
      if answers.length == 0
        return :best => [], :rest => []
      end
      
      group_size = (answers.length.to_f / @groups).ceil
      puts "group_size = #{group_size}"
      
      best = []
      rest = []
      
      answers.shuffle!
      answers.each_slice(group_size) do |group|
        group.each do |a|
          nondominated = true
          
          group.each do |b|
            break unless nondominated &&= a.nondominated_vs?(b, @criteria)
          end
          
          (nondominated ? best : rest) << a
        end
      end
      
      return :best => best,
             :rest => rest
    end
  end
end
