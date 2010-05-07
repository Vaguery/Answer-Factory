module AnswerFactory
  class Factory
    require 'open-uri'
    
    attr_reader :name
    attr_reader :nudge_instructions
    attr_reader :nudge_types
    attr_reader :couchdb_server
    attr_accessor :workstation_names
    attr_reader :original_options_hash
    
    
    def initialize(options = {})
      
      # Factory instance settings
      @name = options[:name] ||
        (configatron.factory.name unless configatron.factory.name.nil?) ||
        "my_factory"
      
      @workstation_names = options[:workstation_names] ||
              (configatron.factory.workstation_names unless configatron.factory.workstation_names.nil?) ||
              Array.new
      
      # CouchDB settings
      @couchdb_server = options[:couchdb_server] ||
              (configatron.factory.couchdb.server unless configatron.factory.couchdb.server.nil?) ||
              "http://127.0.0.1:5984"
      
      # Nudge language settings
      @nudge_instructions = options[:nudge_instructions] ||
        (configatron.nudge.instructions.all unless configatron.nudge.instructions.all.nil?) ||
        Instruction.all_instructions
      
      @nudge_types = options[:nudge_types] ||
          (configatron.nudge.types.all unless configatron.nudge.types.all.nil?) ||
          NudgeType.all_types
      
      
      
      save_configuration!
    end
    
    # this apparent redundancy saves project-based
    # and command-line overrides
    def save_configuration!
      configatron.factory.name = @name
      configatron.nudge.instructions.all = @nudge_instructions
      configatron.nudge.types.all = @nudge_types
      configatron.factory.workstation_names = @workstation_names
      configatron.factory.couchdb.server = @couchdb_server
    end
    
    
    def couch_available?
      open(configatron.couchdb_uri).status
      true
    rescue StandardError
      false 
    end
    
  end
end