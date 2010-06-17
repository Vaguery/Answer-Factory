class Answer
  attr_reader :machine_name
  
  def initialize (*)
  end
  
  def Answer.load_for_workstation (workstation_name)
    []
  end
  
  def Answer.new_empty_collection
    []
  end
  
  def Answer.relocate (answers, workstation_name, machine_name)
  end
  
  def Answer.save (answers)
  end
end
