module AnswerFactory
  
  class Workstation
    attr_reader :name, :capacity, :couchdb_uri, :factory_name
    attr_accessor :downstream_stations
    attr_accessor :answers
    attr_accessor :build_sequence
    
    
    def initialize(name, options = {})
      raise ArgumentError, "#{name} is not a Symbol" unless name.kind_of?(Symbol)
      @name = name
      @factory_name = options[:factory_name] || 'factory_name'
      @couchdb_uri = options[:couchdb_uri] || "http://127.0.0.1:5984/#{@factory_name}"
      @capacity = options[:capacity] || 100
      @build_sequence = options[:build_sequence] || Array.new
      @downstream_stations = Array.new
      @answers = Batch.new
    end
    
    
    def transfer_answer(which, where)
      raise ArgumentError, "#{where} is not a Symbol" unless where.kind_of?(Symbol)
      which.remove_tag(self.name)
      which.add_tag(where)
    end
    
    
    def gather_mine
      result = CouchRest.view("#{@couchdb_uri}/_design/#{@name.to_s}/_view/current")
      puts result
    end
    
    
    def build!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def process_with(operator)
      raise ArgumentError, "Workstation#process_with cannot process with a #{operator.class}" unless
        operator.kind_of?(SearchOperator)
      operator.generate(@answers)
    end
    
    
    def ship!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def ship_to(where, &filter)
      raise ArgumentError, "Workstation#ship_to cannot ship to a #{where.class}" unless
        where.kind_of?(Symbol)
      (@answers.find_all &filter).each {|a| a.add_tag where; a.remove_tag @name}
    end
    
    
    def scrap!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def scrap_if(why, &filter)
      (@answers.find_all &filter).each {|a| a.add_tag :SCRAP; a.remove_tag @name}
    end
    
    def scrap_everything
      scrap_if("everything dies") {|x| true}
    end
    
    
    def cycle
      self.receive!
      self.build!
      self.ship!
      self.scrap!
    end
  end
end