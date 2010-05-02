require 'active_support'
require 'answer-factory'

class Setup_Factory < Thor::Group
  include Thor::Actions
  
  # Define arguments and options
  argument :project_name
  class_options :test_framework => :rspec
  
  desc "Creates a new project folder structure for new Nudge types, instructions, search operators and specs"
  
  def self.source_root
    File.dirname(__FILE__)
  end
  
  def answer_factory_gem_path
    AnswerFactory.gem_root
  end
  
  def set_up_project_in_this_folder
    empty_directory("./lib")
    empty_directory("./lib/nudge/instructions")
    empty_directory("./lib/nudge/types")
    empty_directory("./lib/factory/operators")
    empty_directory("./spec")
  end
  
  def create_runner
    template("#{answer_factory_gem_path}/templates/answer_factory_activate_template.erb", "./activate.rb") unless exists?("./activate.rb")
  end
  
  def create_spec_helper
    template("#{answer_factory_gem_path}/templates/answer_factory_spec_helper_template.erb",
      "#{New_Nudge_Type.source_root}/spec/spec_helper.rb") unless exists?("#{New_Nudge_Type.source_root}/spec/spec_helper.rb")
  end  
  
  def say_byebye
    puts "your answer-factory project is located in directory #{Dir.pwd}\n"
  end
end
