module AnswerFactory
  module Machines
    
    
    class EvaluateWithTestCases < Machine
      attr_accessor :data_in_hand, :sensors
      attr_accessor :test_cases
      attr_reader :name
      attr_reader :csv_filename
      
      def initialize(options = {})
        super
        @name = options[:name] || "evaluator"
        @data_in_hand = options[:data_in_hand] || {}
        @sensors = options[:sensors] || {}
        @csv_filename = options[:training_data_csv]
      end
      
      def score(batch, overridden_options = {})
        all_options = @options.merge(overridden_options)
        name = all_options[:name]
        
        raise ArgumentError, "EvaluateWithTestCases#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        raise ArgumentError, "EvaluateWithTestCases: Undefined #name attribute" if
          name.nil?
        
        batch.each do |a|
          interpreter = Interpreter.new("ref x1",all_options)
          @sensors.each {|s_key, s_value| interpreter.register_sensor(s_key, &s_value)}
        end
        
        
        return batch
      end
      
      
      def training_datasource
        configatron.factory.training_datasource
      end
      
      
      def training_data_view
       "#{configatron.factory.training_datasource}/_design/#{@name}/_view/test_cases"
      end
      
      
      def install_training_data_from_csv(csv_filename = @csv_filename)
        reader = CSV.new(File.open(csv_filename), headers: true)
        reader.readline
        split_point = reader.headers.find_index(nil)
        input_headers = reader.headers[0...split_point]
        output_headers = reader.headers[split_point+1..-1]
        reader.rewind
        
        offset = input_headers.length+1
        db = CouchRest.database!(training_datasource)
        
        reader.each do |row|
          inputs = {}
          input_headers.each_with_index {|header,i| inputs[header] = row[i]}
          outputs = {}
          output_headers.each_with_index {|header,i| outputs[header] = row[i+offset]}
          db.bulk_save_doc( {:inputs => inputs, :outputs => outputs})
        end
        
      end
      
      
      def load_training_data!
        db = CouchRest.database!(training_datasource)
        result = db.view("#{@name}/test_cases")
        @test_cases = 
          result["rows"].collect {|r| TestCase.new(
              inputs: r["value"]["inputs"], outputs: r["value"]["outputs"])}
      end
      
      
      alias :generate :score
    end
    
    
    
    
    class TestCase
      attr_accessor :inputs, :outputs
      
      def initialize(options = {})
        @inputs = options[:inputs] || {}
        @outputs = options[:outputs] || {}
      end
    end
  end
end