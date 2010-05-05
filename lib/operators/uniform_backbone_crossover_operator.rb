module AnswerFactory
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
end