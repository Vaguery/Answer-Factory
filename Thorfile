require 'active_support'
require 'lib/answer-factory'

class Create_Factory < Thor::Group
  include Thor::Actions
  
  # Define arguments and options
  argument :project_name
  class_options :test_framework => :rspec
  
  desc "Creates a new project folder structure for new Nudge types, instructions, search operators and specs"
  
  
  def self.source_root
    File.dirname(__FILE__)
  end
  
  
  def create_factory_folder
    if Dir.exist?(project_name) then
      puts "project directory /#{project_name} already exists"
    else
      empty_directory(project_name)
      empty_directory("#{project_name}/lib")
      empty_directory("#{project_name}/lib/nudge/instructions")
      empty_directory("#{project_name}/lib/nudge/types")
      empty_directory("#{project_name}/lib/factory/operators")
      empty_directory("#{project_name}/spec")
    end
  end
end


class New_Nudge_Type < Thor::Group
  include Thor::Actions
  
  # Define arguments and options
  argument :typename_root
  class_option :test_framework, :default => :rspec
  desc "Creates a new NudgeType class definition file, typical instructions, and rspec files"
  

  def self.source_root
    File.dirname(__FILE__)
  end
  
  def self.type_name(string)
    string.camelize + "Type"
  end
  
  def nudge_gem_path
    Nudge.gem_root
  end
  
  def create_lib_file
    @camelcased_type_name = New_Nudge_Type.type_name(typename_root)
    filename = "#{@camelcased_type_name}.rb"
    template("#{nudge_gem_path}/templates/nudge_type_class.erb", "#{New_Nudge_Type.source_root}/lib/types/#{filename}")
  end
  
  def create_lib_spec
    @camelcased_type_name = New_Nudge_Type.type_name(typename_root)
    filename = "#{@camelcased_type_name}_spec.rb"
    template("#{nudge_gem_path}/templates/nudge_type_spec.erb", "#{New_Nudge_Type.source_root}/spec/#{filename}")
  end  
  
  def create_instructions
    suite = ["define", "equal_q", "duplicate", "flush", "pop",
      "random", "rotate", "shove", "swap", "yank", "yankdup"]
    
    suite.each do |inst|
      @core = "#{typename_root}_#{inst}"
      filename = "#{@core}.rb"
      @instname = "#{@core.camelize}Instruction"
      @type = typename_root
      @camelized_type = New_Nudge_Type.type_name(typename_root)
      template("#{nudge_gem_path}/templates/nudge_#{inst}_instruction.erb", "#{New_Nudge_Type.source_root}/lib/instructions/#{filename}")
    end
  end
end