class Answer
  attr_reader :id,
              :scores
  
  attr_accessor :blueprint,
                :workstation,
                :machine,
                :language,
                :progress
  
  def initialize (properties, id = nil, blueprint = nil, workstation = nil, machine = nil, language = nil, progress = nil)
    @id = id
    @blueprint = blueprint || properties[:blueprint] || "block {}\n"
    @workstation = workstation || properties[:workstation] || "NULL"
    @machine = machine || properties[:machine] || "NULL"
    @language = language || properties[:language] || "NULL"
    @progress = (progress || properties[:progress] || 0).to_i
    @scores = {}
  end
  
  def score (name_or_hash)
    if name_or_hash.is_a? Symbol
      score = (@scores[name_or_hash] ||= Score.new(:name => name_or_hash, :value => Factory::Infinity))
      return score.value
    end
    
    name_or_hash.each do |name, value|
      if score = @scores[name]
        score.value = value
      else
        @scores[name] = Score.new(:name => name, :value => value || Factory::Infinity)
      end
    end
  end
end
