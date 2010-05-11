module AnswerFactory
  
  class Workstation
    attr_reader :name, :capacity, :factory_name
    attr_accessor :downstream_stations
    attr_accessor :answers
    
    
    def initialize(name, options = {})
      raise ArgumentError, "#{name} is not a Symbol" unless name.kind_of?(Symbol)
      @name = name
      @factory_name = configatron.factory.name
      @capacity = options[:capacity] || 100
      @downstream_stations = Array.new
      @answers = Batch.new
    end
    
    
    def transfer_answer(which, where)
      raise ArgumentError, "#{where} is not a Symbol" unless where.kind_of?(Symbol)
      which.remove_tag(self.name)
      which.add_tag(where)
    end
    
    def couchdb_uri
      "#{configatron.factory.couchdb.server}/#{configatron.factory.couchdb.name}"
    end
    
    
    def receive!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def gather_mine
      gathered = Batch.load_from_couch(couchdb_uri, "#{name}/current")
      @answers = gathered
    end
    
    
    def build!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def process_with(operator)
      raise ArgumentError, "Workstation#process_with cannot process with a #{operator.class}" unless
        operator.kind_of?(Machines::Machine)
      operator.generate(@answers)
    end
    
    
    def ship!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def ship_to(where)
      raise ArgumentError, "Workstation#ship_to cannot ship to a #{where.class}" unless
        where.kind_of?(Symbol)
        
      @answers.each do |a|
        next unless a.location.to_sym == @name.to_sym
        if block_given?
          next unless yield(a)
        end
        a.move_to(where)
      end
    end
    
    
    def scrap!
      # Workstation is a superclass; the default behavior (doing nothing)
      # should be overridden in a subclass definition
    end
    
    
    def scrap_if(why, &filter)
      ship_to(:SCRAP, &filter) 
      # (@answers.find_all &filter).each {|a| a.add_tag :SCRAP; a.remove_tag @name}
    end
    
    def scrap_everything
      ship_to(:SCRAP)
    end
    
    
    def after_cycle!
      @answers.bulk_save!(couchdb_uri)
      @answers = Batch.new
    end
    
    def cycle
      self.receive!
      self.build!
      self.ship!
      self.scrap!
      self.after_cycle!
    end
  end
end