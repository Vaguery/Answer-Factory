module NudgeGP
  class Workstation
    attr_reader :name, :capacity, :couchdb_uri, :factory_name
    attr_accessor :downstream_stations
    attr_accessor :answers
    
    
    def initialize(name, options = {})
      raise ArgumentError, "#{name} is not a Symbol" unless name.kind_of?(Symbol)
      @name = name
      @factory_name = options[:factory_name] || 'factory_name'
      @couchdb_uri = options[:couchdb_uri] || "http://127.0.0.1:5984/#{@factory_name}"
      @capacity = options[:capacity] || 100
      @downstream_stations = Array.new
      @answers = Array.new
    end
    
    
    def transfer_answer(which, where)
      raise ArgumentError, "#{where} is not a Symbol" unless where.kind_of?(Symbol)
      which.remove_tag(self.name)
      which.add_tag(where)
    end
    
    
    def cycle
      self.receive!
      self.build!
      self.ship!
      self.scrap!
    end
  end
end