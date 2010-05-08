module AnswerFactory
  class PointMutationOperator < SearchOperator
    
    def generate(crowd, howManyCopies = 1, overridden_options ={})
      raise(ArgumentError) if !crowd.kind_of?(Array)
      raise(ArgumentError) if crowd.empty?
      crowd.each {|dude| raise(ArgumentError) if !dude.kind_of?(Answer) }
      
      result = Batch.new
      crowd.each do |dude|
        howManyCopies.times do
          where = rand(dude.points)+1
          newCode = CodeType.any_value(@incoming_options.merge(overridden_options))
          variant = dude.replace_point_or_clone(where,newCode)
          baby = Answer.new(variant, progress:dude.progress + 1)
          result << baby 
        end
      end
      return result
    end
  end
end