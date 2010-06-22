class Answer
  include DataMapper::Resource
  
  property :id, Serial
  property :blueprint, Text, :lazy => false
  property :workstation_name, String
  property :machine_name, String
  property :locked, Boolean
  
  def machine_name
    @machine_name.intern if @machine_name
  end
  
  def workstation_name
    @workstation_name.intern
  end
  
  def Answer.load_for_workstation (workstation_name)
    answers = Answer.all(:workstation_name => workstation_name, :locked => false)
    answers.update(:locked => true)
    answers
  end
  
  def Answer.new_empty_collection
    Answer.all(:id => 0)
  end
  
  def Answer.relocate (answers, workstation_name, machine_name)
    answers.each do |answer|
      answer.workstation_name = workstation_name
      answer.machine_name = machine_name
      answer.locked = false
    end
  end
  
  def Answer.save (answers)
    answers.save
  end
end
