class Score
  attr_reader   :id
  attr_accessor :name,
                :value
  
  def initialize (properties, id = nil, name = nil, value = nil)
    @id = id
    @name = (name || properties[:name]).to_sym
    @value = (value || properties[:value]).to_f
  end
end
