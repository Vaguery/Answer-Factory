module AnswerFactory
  module Machines
    
    
    class EvaluateWithTestCases < Machine
      attr_accessor :data_in_hand, :sensors
      attr_accessor :test_cases
      attr_reader :name
      
      def initialize(options = {})
        super
        @name = options[:name] || "evaluator"
        @data_in_hand = options[:data_in_hand] || {}
        @sensors = options[:sensors] || {}
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
      
      
      def load_training_data!
        
        # expected = {"total_rows"=>1, "offset"=>0, "rows"=>[{"id"=>"05d195b7bb436743ee36b4223008c4ce", "key"=>"05d195b7bb436743ee36b4223008c4ce", "value"=>{"_id"=>"05d195b7bb436743ee36b4223008c4ce", "_rev"=>"1-c9fae927001a1d4789d6396bcf0cd5a7", "inputs"=>{"x1"=>7}, "outputs"=>{"y1"=>12}}}]}
        
        db = CouchRest.database!(training_datasource)
        result = db.view("#{@name}/test_cases")
        @test_cases = 
          result["rows"].collect {|r| TestCase.new(inputs: r["value"]["inputs"], outputs: r["value"]["outputs"])}
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