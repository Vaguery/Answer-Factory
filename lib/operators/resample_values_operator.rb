#encoding: utf-8
module AnswerFactory
  
  class ResampleValuesOperator < SearchOperator
  
    def generate(crowd, howManyCopies = 1, overridden_options = {})
      crowd.each {|dude| raise(ArgumentError) if !dude.kind_of?(Answer) }
    
      result = Batch.new
      regenerating_options = @incoming_options.merge(overridden_options)
      crowd.each do |dude|
        howManyCopies.times do
          wildtype_program = dude.program
          starting_footnotes = wildtype_program.footnote_section.split( /^(?=«)/ )
          breaker = /^«([a-zA-Z][a-zA-Z0-9_]*)»\s*(.*)\s*/m
          type_value_pairs = starting_footnotes.collect {|fn| fn.match(breaker)[1..2]}
        
          mutant_blueprint = wildtype_program.code_section
        
          type_value_pairs.each do |pair|
          
            begin
              type_name = pair[0]
              type_class = "#{type_name}_type".camelize.constantize
              reduced_size = regenerating_options[:target_size_in_points] || rand(dude.points/2)
              reduced_option = {target_size_in_points:reduced_size}
              resampled_value = type_class.any_value(regenerating_options.merge(reduced_option)).to_s
            rescue NameError
              resampled_value = pair[1]
            end            
            mutant_blueprint << "\n«#{pair[0].strip}» #{resampled_value.strip}"
          end
          mutant = Answer.new(mutant_blueprint, progress:dude.progress + 1)
          result << mutant
        end
      end
      return result
    end
  end
end
