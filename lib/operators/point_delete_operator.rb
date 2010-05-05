module AnswerFactory
  class PointDeleteOperator < SearchOperator
    def generate(crowd, howManyCopies = 1)
      raise(ArgumentError) if !crowd.kind_of?(Array)
      crowd.each {|dude| raise(ArgumentError) if !dude.kind_of?(Answer) }
      
      result = Batch.new
      crowd.each do |dude|
        howManyCopies.times do
          where = rand(dude.points)+1
          variant = dude.delete_point_or_clone(where)
          baby = Answer.new(variant, progress:dude.progress + 1)
          result << baby
        end
      end
      return result
    end
  end
end