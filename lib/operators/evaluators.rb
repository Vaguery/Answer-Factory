module AnswerFactory
  
  class Evaluator < SearchOperator
    attr_accessor :name
    
    def initialize(params = {})
      raise(ArgumentError, "Evaluators must be initialized with names") if params[:name] == nil
      @name = params[:name]
    end
  end
  
  
  
  
  
  class ProgramPointEvaluator < Evaluator
    def evaluate(batch)
      raise(ArgumentError, "Can only evaluate a Batch of Answers") if !batch.kind_of?(Batch)
      batch.each do |i|
        if i.parses?
          i.scores[@name] = i.program.points
        else
          raise(ArgumentError, "Program is not parseable")
        end
      end
    end
  end
  
  
  
  
  
  class TestCase
    attr_accessor :bindings, :expectations, :gauges
    
    def initialize(args = {})
      @bindings = args[:bindings] || Hash.new
      @expectations = args[:expectations] || Hash.new
      @gauges = args[:gauges] || Hash.new
      
      if (@expectations.keys - @gauges.keys).length > 0
        raise ArgumentError, "One or more expectations have no defined gauge"
      end
    end
  end
  
  
  
  
  
  class TestCaseEvaluator < Evaluator
    attr_accessor :interpreter_settings
    
    def evaluate(batch, cases = [], params = {})
      raise(ArgumentError, "Can only evaluate a Batch of Answers") if !batch.kind_of?(Batch)
      
      instructions = params[:instructions] || Instruction.all_instructions
      types = params[:types] || [IntType, BoolType, FloatType]
      variable_names = params[:references] || []
      
      batch.each do |dude|
        if !params[:deterministic] || !dude.scores[@name]
          score = 0
          readings = {}
          cases.each do |example|
            difference = 0
          
            # make an Interpreter
            workspace = Interpreter.new("",
              :instruction_names => instructions,
              :type_names => types,
              :references => variable_names)
          
            # set up the program
            workspace.reset(dude.blueprint)
          
            # set up the bindings
            example.bindings.each do |key,value|
              workspace.bind_variable(key, value)
            end
          
            # run it
            workspace.run
          
            # apply the gauge(s) for each expectation
            example.gauges.each do |variable_name,the_gauge|
              readings[variable_name] = the_gauge.call(workspace)
            end
          
            # synthesize readings into a single scalar difference
            # FIXME this should be a settable Proc
            example.gauges.each do |variable_name,the_gauge|
              begin
                difference = (readings[variable_name].value - example.expectations[variable_name])
              rescue
                difference = 100000
              end
            end
          
            score += difference.abs
          end
          # aggregate differences
          dude.scores[@name] = score.to_f / cases.length
        
          puts "#{score.to_f / cases.length}" if params[:feedback]
        else
          puts dude.scores[@name] if params[:feedback]
        end
      end
    end
    
  end
end