#encoding: utf-8
module AnswerFactory
  module Machines
    
    
    
    
    class MutateFootnotesUniform < Machine
      
      def build(batch, overridden_options={})
        raise ArgumentError, "MutateFootnotesUniform#build cannot process a #{batch.class}" unless
          batch.kind_of?(Batch)
        
        all_options = @options.merge(overridden_options)
          
        fraction = all_options[:proportion_changed] || 0.5
        fraction = 0.0 if fraction < 0.0
        fraction = 1.0 if fraction > 1.0
        
        replicates = all_options[:replicates] || 1
        
        result = Batch.new
        
        batch.each do |orig|
          
          codeblock = orig.program.code_section.strip
          fn = orig.program.footnote_section.split(/^(?=«)/)
          fn_count = fn.length
          
          replicates.times do
            changes = (fraction*fn_count).ceil
            which_fns_change = (0...fn_count).to_a.sample(changes)
            new_blueprint = "#{codeblock} \n"
            (0...fn_count).each do |f|
              new_fn = which_fns_change.include?(f) ? mutated_footnote_value(fn[f],all_options) : fn[f]
              new_blueprint << "\n#{new_fn.strip}"
            end
            result << Answer.new(new_blueprint)
          end
        end
        
        return result
      end
      
      
      def mutated_footnote_value(footnote_string, options = {})
        type = /^«([\p{Alpha}][_\p{Alnum}]*)(?=»)/.match(footnote_string)[1]
        nudgified = "#{type}_type".camelize
        Nudge.const_defined?(nudgified) ? 
          "«#{type}» #{nudgified.constantize.any_value(options)}" : 
          footnote_string
      end
      
      
      
      alias :generate :build
      
      
    end
  end
end