module AnswerFactory
  class Factory
    require 'open-uri'
    
    attr_reader :name
    attr_reader :nudge_instructions
    attr_reader :nudge_types
    attr_reader :couchdb_server, :couchdb_name
    attr_accessor :workstation_names
    attr_reader :original_options_hash
    
    
    def initialize(options = {})
      
      # Factory instance settings
      @name = options[:name] ||
        configatron.factory.retrieve(:name,nil) ||
        "my_factory"
      
      @workstation_names = options[:workstation_names] ||
        configatron.factory.retrieve(:workstation_names, nil) ||
        Array.new
      
      
      # CouchDB settings
      @couchdb_server = options[:couchdb_server] ||
        configatron.factory.couchdb.retrieve(:server, nil) ||
        "http://127.0.0.1:5984"
      
      @couchdb_name = options[:couchdb_name] ||
        configatron.factory.couchdb.retrieve(:name, nil) ||
        @name
      
      
      # Nudge language settings
      @nudge_instructions = options[:nudge_instructions] ||
        configatron.nudge.instructions.retrieve(:all, nil) ||
        Instruction.all_instructions
      
      @nudge_types = options[:nudge_types] ||
        configatron.nudge.types.retrieve(:all, nil) ||
        NudgeType.all_types
      
      update_configatron!
    end
    
    
    # this apparent redundancy saves project-based
    # and command-line overrides
    def update_configatron!
      configatron.factory.name = @name
      configatron.nudge.instructions.all = @nudge_instructions
      configatron.nudge.types.all = @nudge_types
      configatron.factory.workstation_names = @workstation_names
      configatron.factory.couchdb.server = @couchdb_server
      configatron.factory.couchdb.name = @couchdb_name
    end
    
    
    def self.couch_available?
      open(configatron.factory.couchdb.server).status
      true
    rescue StandardError
      false 
    end
    
  end
end