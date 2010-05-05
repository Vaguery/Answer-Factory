module AnswerFactory
  class PointCrossoverOperator < SearchOperator
    def generate(crowd, howManyBabies = 1)
      raise(ArgumentError) if !crowd.kind_of?(Array)
      raise(ArgumentError) if crowd.empty?
      crowd.each {|dude| raise(ArgumentError) if !dude.kind_of?(Answer) }
      
      result = Batch.new
      production = crowd.length*howManyBabies
      production.times do
        mom = crowd.sample
        dad = crowd.sample
        mom_receives = rand(mom.points) + 1
        dad_donates = rand(dad.points) + 1
        
        baby_blueprint = mom.replace_point_or_clone(mom_receives,dad.program[dad_donates])
        baby = Answer.new(baby_blueprint,
          progress:[mom.progress,dad.progress].max + 1)
        result << baby
      end
      return result
    end
  end
end