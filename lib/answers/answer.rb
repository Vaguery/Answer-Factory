require 'set'

module AnswerFactory
  class Answer
    attr_accessor :scores, :tags
    attr_reader :draft_blueprint, :program, :timestamp, :ancestors
    attr_reader :initialization_options, :progress, :couch_id
    
    
    def initialize(blueprint, options = {})
      raise ArgumentError unless
        blueprint.kind_of?(String) || blueprint.kind_of?(NudgeProgram)
      build_from_blueprint!(blueprint)
      
      @scores = options[:scores] || Hash.new do |hash, key|
        raise ArgumentError, "scores must use symbols as keys" unless key.kind_of?(Symbol)
        nil
      end
      @timestamp = Time.now
      @couch_id = options[:couch_id] || ""
      @progress = options[:progress] || 0
      @ancestors = options[:ancestors] || []
      @tags = Set.new(options[:tags]) || Set.new
      
      @initialization_options = options
    end
    
    
    def build_from_blueprint!(blueprint)
      if blueprint.kind_of?(String)
        @draft_blueprint = blueprint
        @program = NudgeProgram.new(blueprint)
      else
        @program = blueprint
        @draft_blueprint = @program.blueprint
      end
    end
    
    
    def blueprint
      @program.blueprint
    end
    
    
    def parses?
      @program.parses?
    end
    
    
    def known_criteria
      @scores.keys.sort
    end
    
    
    def score_vector(ordering = known_criteria)
      ordering.collect {|k| @scores[k]}
    end
    
    
    def dominated_by?(other_answer, comparison_criteria = self.known_criteria)
      
      return false unless (known_criteria & comparison_criteria) ==
        (other_answer.known_criteria & comparison_criteria)
      
      could_be_identical = true
      
      comparison_criteria.each do |score|
        return false if (my_score = self.scores[score]) < (other_score = other_answer.scores[score])
        
        if could_be_identical
          could_be_identical &&= (my_score == other_score)
        end
      end
      
      return !could_be_identical
    rescue NoMethodError
      false
    end
    
    
    def points
      @program.points
    end
    
    
    def delete_point_or_clone(which)
      ((1..self.points).include?(which)) ?
        self.program.delete_point(which) : 
        self.program.deep_copy
    end
    
    
    def replace_point_or_clone(which, object)
      if object.kind_of?(String)
        prog = NudgeProgram.new(object)
        if !prog.parses?
          raise(ArgumentError, "Replacement point cannot be parsed")
        else
          new_point = prog.linked_code
        end
      elsif object.kind_of?(ProgramPoint)
        new_point = object
      else
        raise(ArgumentError, "Program points cannot be replaced by #{object.class} objects")
      end
      
      ((1..self.points).include?(which)) ?
        self.program.replace_point(which, new_point) :
        self.program.deep_copy
    end
  end
  
  
  def add_tag(new_tag)
    raise ArgumentError, "#{new_tag} is not a Symbol" unless new_tag.kind_of?(Symbol)
    @tags.add(new_tag)
  end
  
  
  def remove_tag(old_tag)
    @tags.delete(old_tag)
  end
  
  
  def data
    {'blueprint' => self.blueprint,
      'tags' => self.tags, 
      'scores' => self.scores,
      'progress' => self.progress,
      'timestamp' => self.timestamp}
  end
  
  
  def from_serial_hash(hash)
    value_hash = hash["value"]
    tag_set = Set.new(value_hash["tags"].collect {|t| t.to_sym})
    symbolized_scores = value_hash["scores"].inject({}) {|memo,(k,v)| memo[k.to_sym] = v; memo }
    
    Answer.new(value_hash["blueprint"],
      couch_id:value_hash["_id"],
      tags:tag_set,
      scores:symbolized_scores,
      progress:value_hash["progress"])
  end
end