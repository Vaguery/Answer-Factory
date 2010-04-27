module NudgeGP
  # A Batch is simply an Array of Answers, with validation for all assignment methods
  class Batch < Array
    
    def self.[](*args)
      raise ArgumentError unless args.inject(true) {|anded, a| anded & a.kind_of?(Answer)}
      super
    end
    
    
    def []=(index, obj)
      raise ArgumentError unless obj.kind_of?(Answer)
      super
    end
    
    
    def <<(obj)
      raise ArgumentError unless obj.kind_of?(Answer)
      super
    end
    
    
    def initialize(*args)
      raise ArgumentError unless args.inject(true) {|anded, a| anded & a.kind_of?(Answer)}
      super
    end
    
    
    def bulk_save!(couchdb_uri)
      raise ArgumentError, "#{couchdb_uri} is not a String" unless couchdb_uri.kind_of?(String)
      
      db = CouchRest.database!(couchdb_uri)
      db.bulk_save(self.data)
    end
    
    
    def self.load_tagged_answers(couchdb_uri, tag)
      raise ArgumentError, "#{couchdb_uri} is not a String" unless couchdb_uri.kind_of?(String)
      raise ArgumentError, "#{tag} is not a String" unless tag.kind_of?(String)
      db = CouchRest.database(couchdb_uri) # add the view document and key here
      return Batch.new
    end
    
    
    def data
      self.collect {|i| i.data}
    end
  end
end
