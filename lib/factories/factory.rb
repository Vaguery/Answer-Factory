module AnswerFactory
  class Factory
    require 'open-uri'
    require 'configatron'
    
    attr_reader :name
    attr_reader :instruction_library, :type_library
    attr_accessor :workstation_names
    attr_reader :original_options_hash
    
    
    def initialize(name = "my_factory", options = {})
      @name = name
      @original_options_hash = options
      @instruction_library = options[:instruction_library] || Instruction.all_instructions
      @type_library = options[:type_library] || NudgeType.all_types
      @workstation_names = Array.new
      
      self.configure!
    end
    
    
    def couch_available?
      open(self.configatron.couchdb_uri).status
      true
    rescue StandardError
      false 
    end
    
    
    
    def configure!
      self.configure_constants!
      self.configure_paths!
      self.configure_databases!
    end
    
    
    def configure_constants!
      self.configatron.factory_name = self.name
    end
    
    
    def configure_paths!
      self.configatron.factory_root = File.expand_path("#{File.dirname(__FILE__)}/../..")
    end
    
    
    def configure_databases!
      self.configatron.configure_from_yaml("#{self.configatron.factory_root}/config/database.yml")
      self.configatron.couchdb_uri = "#{self.configatron.main_database.db_root}/#{self.name}"
    end
  end
end