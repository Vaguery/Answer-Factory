# encoding: UTF-8
class Machine
  def initialize (location, &config)
    @location = location.to_s
    @routes = {}
    @process = proc { process_answers }
    @load_scores = true
    
    self.instance_eval(&config) if config
  end
  
  def process_answers
    raise NoMethodError, "define process for machine #{@location} before running factory"
  end
  
  def process (&block)
    @process = block
  end
  
  def send (hash)
    @routes.merge! hash
  end
  
  def load_without_scores (arg)
    @load_scores = !arg
  end
  
  def answers
    @answers
  end
  
  def run
    @answers = Factory.load_answers(@location, @load_scores)
    
    raise SomeError unless (output_hash = @process.call).is_a?(Hash)
    
    answers_to_save = []
    
    output_hash.each do |route_name, output_answers|
      location = @routes[route_name]
      
      output_answers.each do |answer|
        answers_to_save << answer.assign(location)
      end
    end
    
    Factory.save_answers(answers_to_save)
  end
end
