require File.join(File.dirname(__FILE__), "./../spec_helper")

require 'fileutils'
include FileUtils::Verbose

describe "Setup_Factory" do
  before(:each) do
    @startpoint = Dir.pwd
    @project_name = "spec_thor_makeshift_projectname"
    rmtree("./spec/scratch/#{@project_name}") if Dir.exists?("./spec/scratch/#{@project_name}")
    Dir.mkdir("./spec/scratch/#{@project_name}")
    Dir.chdir("./spec/scratch/#{@project_name}")
  end
  
  after(:each) do
    Dir.chdir(@startpoint)
    rmtree("./spec/scratch/#{@project_name}") if Dir.exists?("./spec/scratch/#{@project_name}")
  end
  
  it "should create a subdirectory /lib in the current directory"
  
  # it "should create a subdirectory /lib/factory/machines in the current directory"
  # 
  # it "should create a subdirectory /lib/nudge/types in the current directory"
  # 
  # it "should create a subdirectory /lib/nudge/instructions in the current directory"
  #   
  # it "should create a subdirectory /spec in the current directory"
  # 
  # it "should create (copy) activate.rb"
  # 
  # it "should create (copy) /spec/spec_helper.rb"
end