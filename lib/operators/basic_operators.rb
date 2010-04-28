#encoding: utf-8
module AnswerFactory
  
  # Abstract class that from which specific SearchOperator subclasses inherit initialization
  
  class SearchOperator
    attr_accessor :incoming_options
    
     def initialize(options={})
       @incoming_options = options
     end
  end
  
  
  
  
  class RandomGuessOperator < SearchOperator
    
    # returns an Array of random Answers
    #
    # the first (optional) parameter specifies how many to make, and defaults to 1
    # the second (also optional) parameter is a hash that
    # can temporarily override those set in the initialization
    #
    # For example, if
    # <tt>myRandomGuesser = RandomGuessOperator.new(:randomIntegerLowerBound => -90000)</tt>
    #
    # [<tt>myRandomGuesser.generate()</tt>]
    #   produces a list of 1 Answer, and if it has any IntType samples they will be in [-90000,100]
    #   (since the default +:randomIntegerLowerBound+ is 100)
    # [<tt>myRandomGuesser.generate(1,:randomIntegerLowerBound => 0)</tt>]
    #   makes one Answer whose IntType samples (if any) will be between [0,100]
    
    def generate(howMany = 1, overridden_options ={})
      result = Batch.new
      howMany.times do
        newGenome = CodeType.any_value(@incoming_options.merge(overridden_options))
        newDude = Answer.new(newGenome, progress:0)
        result << newDude
      end
      result
    end
  end
  
  
  
  
  class ResampleAndCloneOperator < SearchOperator
    
    # returns an Array of clones of Answers randomly selected from the crowd passed in
    # 
    # the first (required) parameter is an Array of Answers
    # the second (optional) parameter is how many samples to take, and defaults to 1
    #
    # For example, if
    # <tt>@currentPopulation = [a list of 300 Answers]</tt> and
    # <tt>myRandomSampler = ResampleAndCloneOperator.new(@currentPopulation)</tt>
    # [<tt>myRandomSampler.generate()</tt>]
    #   produces a list of 1 Answer, which is a clone of somebody from <tt>@currentPopulation</tt>
    # [<tt>myRandomGuesser.generate(11)</tt>]
    #   returns a list of 11 Answers cloned from <tt>@currentPopulation</tt>,
    #   possibly including repeats
    
    def generate(crowd, howMany = 1)
      result = Batch.new
      howMany.times do
        donor = crowd.sample
        clone = Answer.new(donor.blueprint, progress:donor.progress + 1)
        result << clone
      end
      return result
    end
  end
  
  
  
  
  class ResampleValuesOperator < SearchOperator
    
    def generate(crowd, howManyCopies = 1, overridden_options = {})
      crowd.each {|dude| raise(ArgumentError) if !dude.kind_of?(Answer) }
      
      result = Batch.new
      regenerating_options = @incoming_options.merge(overridden_options)
      crowd.each do |dude|
        howManyCopies.times do
          wildtype_program = dude.program
          starting_footnotes = wildtype_program.footnote_section.split( /^(?=«)/ )
          breaker = /^«([a-zA-Z][a-zA-Z0-9_]*)»\s*(.*)\s*/m
          type_value_pairs = starting_footnotes.collect {|fn| fn.match(breaker)[1..2]}
          
          mutant_blueprint = wildtype_program.code_section
          
          type_value_pairs.each do |pair|
            
            begin
              type_name = pair[0]
              type_class = "#{type_name}_type".camelize.constantize
              reduced_size = regenerating_options[:target_size_in_points] || rand(dude.points/2)
              reduced_option = {target_size_in_points:reduced_size}
              resampled_value = type_class.any_value(regenerating_options.merge(reduced_option)).to_s
            rescue NameError
              resampled_value = pair[1]
            end            
            mutant_blueprint << "\n«#{pair[0].strip}» #{resampled_value.strip}"
          end
          mutant = Answer.new(mutant_blueprint, progress:dude.progress + 1)
          result << mutant
        end
      end
      return result
    end
  end
  
  
  
  
  class UniformBackboneCrossoverOperator < SearchOperator
    
    # Returns a Batch of new Answers whose programs are made by stitching together
    # the programs of pairs of 'parents'. The incoming Batch is divided into pairs based on
    # adjacency (modulo the Batch.length), one pair for each 'offspring' to be made. To make
    # an offspring, the number of backbone program points is determined in each parent; 'backbone'
    # refers to the number of branches directly within the root of the program, not the entire tree.
    #
    # To construct an offspring's program, program points are copied from the first parent with
    # probability p, or the second parent with probability (1-p), for each point in the first
    # parent's backbone. So if there are 13 and 6 points, respectively, the first six points are
    # selected randomly, but the last 7 are copied from the first parent. If there are 8 and 11
    # respectively, then the last 3 will be ignored from the second parent in any case.
    #   
    #   the first (required) parameter is an Array of Answers
    #   the second (optional) parameter is how many crossovers to make,
    #     which defaults to the number of Answers in the incoming Batch
    
    def generate(crowd, howMany = crowd.length, prob = 0.5)
      result = Batch.new
      howMany.times do
        where = rand(crowd.length)
        mom = crowd[where]
        dad = crowd[ (where+1) % crowd.length ]
        mom_backbone_length = mom.program[1].contents.length
        dad_backbone_length = dad.program[1].contents.length
        
        baby_blueprint_parts = ["",""]
        (0..mom_backbone_length-1).each do |backbone_point|
          if rand() < prob
            next_chunks = mom.program[1].contents[backbone_point].blueprint_parts || ["",""]
          else
            if backbone_point < dad_backbone_length
              next_chunks = (dad.program[1].contents[backbone_point].blueprint_parts || ["", ""])
            else
              next_chunks = ["",""]
            end
          end
          baby_blueprint_parts[0] << " #{next_chunks[0]}"
          baby_blueprint_parts[1] << " \n#{next_chunks[1]}"
        end
        mom.program.unused_footnotes.each {|fn| baby_blueprint_parts[1] += "\n#{fn}"}
        
        baby_blueprint = "block {#{baby_blueprint_parts[0]}} #{baby_blueprint_parts[1]}"
        baby = Answer.new(baby_blueprint, progress:[mom.progress,dad.progress].max + 1)
        
        result << baby
      end
      return result
    end
  end
  
  
  
  
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