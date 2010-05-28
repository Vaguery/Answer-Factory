#encoding: utf-8
module AnswerFactory
  module Machines
    
    
    class EvaluateWithTestCases < Machine
      attr_accessor :sensors
      attr_accessor :test_cases
      attr_reader :name
      attr_reader :csv_filename
      
      def initialize(options = {})
        super
        @name = options[:name] || "evaluator"
        @sensors = options[:sensors] || {}
        @csv_filename = options[:training_data_csv]
        
        # self.load_training_data!
      end
      
      
      def score(batch, overridden_options = {})
        all_options = @options.merge(overridden_options)
        name = all_options[:name]
        
        
        raise ArgumentError, "EvaluateWithTestCases#score cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        raise ArgumentError, "EvaluateWithTestCases: Undefined #name attribute" if
          name.nil?
        
        load_training_data!
        
        batch.each do |answer|
          
          raw_results = Hash.new {|hash, key| hash[key] = []}
          
          @test_cases.each do |t|
            
            interpreter = Interpreter.new(answer.blueprint,all_options)
            
            t.inputs.each do |variable_header, variable_value|
              variable_name, variable_type = variable_header.split(":")
              interpreter.bind_variable(variable_name, ValuePoint.new(variable_type, variable_value))
            end
            
            @sensors.each do |sensor_name, sensor_block|
              interpreter.register_sensor(sensor_name, &sensor_block)
            end
            
            interpreter.run.each do |sensor_name, sensor_result|
              raw_results[sensor_name] << (t.outputs[sensor_name].to_i - sensor_result)
            end
          end
          
          @sensors.each do |sensor_name, sensor_block|
            answer.scores[sensor_name] = raw_results[sensor_name].inject(0) do |sum, measurement|
              sum + measurement.abs
            end
          end
        end
        
        
        return batch
      end
      
      
      def training_datasource
        configatron.factory.training_datasource
      end
      
      
      def training_data_view
       "#{configatron.factory.training_datasource}/_design/#{@name}/_view/test_cases"
      end
      
      
      def header_prep(header_string)
        raise ArgumentError, "Header must match /reference_name:nudge_type/" unless
          header_string.match /[\p{Alpha}][\p{Alnum}_]*:[\p{Alpha}][\p{Alnum}_]/
        header_string.strip
      end
      
      
      def build_sensor(name, &block)
        @sensors[name] = block
      end
      
      
      def save_view_doc!
        db = CouchRest.database!(training_datasource)
        db.save_doc({'_id' => "_design/#{@name}",
          views: { test_cases: { map: "function(doc) { emit(doc._id, doc); }"}}})
      end
      
      
      def install_training_data_from_csv(csv_filename = @csv_filename)
        reader = CSV.new(File.open(csv_filename), headers: true)
        reader.readline
        split_point = reader.headers.find_index(nil)
        
        input_headers = reader.headers[0...split_point].collect {|head| header_prep(head)}
        output_headers = reader.headers[split_point+1..-1].collect {|head| head.strip}
        
        reader.rewind
        
        save_view_doc!
        
        offset = input_headers.length+1
        db = CouchRest.database!(training_datasource)
        
        reader.each do |row|
          inputs = {}
          input_headers.each_with_index {|header,i| inputs[header] = row[i].strip}
          outputs = {}
          output_headers.each_with_index {|header,i| outputs[header] = row[i+offset].strip}
          db.bulk_save_doc( {:inputs => inputs, :outputs => outputs})
        end
        
        db.bulk_save
        
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