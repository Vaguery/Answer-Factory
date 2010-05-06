module AnswerFactory
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
    
    
    def self.load_from_couch(couchdb_uri, design_doc)
      raise ArgumentError, "#{couchdb_uri} is not a String" unless couchdb_uri.kind_of?(String)
      raise ArgumentError, "#{design_doc} is not a String" unless design_doc.kind_of?(String)
      
      batch = Batch.new
      
      db = CouchRest.database(couchdb_uri) # add the view document and key here
      begin
        response = db.view(design_doc)
        response["rows"].each do |hash|
          puts hash["values"]
          batch << Answer.from_serial_hash(hash)
        end
      rescue JSON::ParserError => e
        puts "Batch not read due to JSON ParserError: '#{e.message}'"
      end
      return batch
    end
    
    
    def data
      self.collect {|i| i.data}
    end
  end
end
