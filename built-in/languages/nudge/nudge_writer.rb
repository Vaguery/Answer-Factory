# encoding: UTF-8
class NudgeWriter < Writer
  def initialize
    @footnotes_needed = []
    
    @block_width = 5
    @block_depth = 5
    @code_recursion = 5
    
    use_instructions *NudgeInstruction::INSTRUCTIONS.keys
    use_refs :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10
    use_random_values *([:bool, :code, :float, :int, :proportion] + NudgeValue::TYPES.keys)
    
    weight block: 1, do: 1, ref: 1, value: 1
    float_range(-100..100)
    int_range(-100..100)
    
    setup
  end
  
  def language
    :Nudge
  end
  
  def random
    NudgeBlueprint.new("#{generate_block(@block_depth)}\n#{generate_footnotes}")
  end
  
  def random_value (value_type)
    "#{generate_value(value_type)}\n#{generate_footnotes}"
  end
  
  def block_width (n)
    @block_width = n
  end
  
  def block_depth (n)
    @block_depth = n
  end
  
  def code_recursion (n)
    @code_recursion = n
  end
  
  def use_instructions (*instructions)
    @do_instructions = instructions - [:block, :do, :ref, :value]
  end
  
  def use_refs (*names)
    @ref_names = names - [:block, :do, :ref, :value]
  end
  
  def use_random_values (*value_types)
    @value_types = value_types - [:block, :do, :ref, :value, :name, :exec, :error]
    @code_type_switch = *@value_types.delete(:code)
  end
  
  def weight (weight)
    block_weight = (weight[:block] || 0).to_f
    do_weight = (weight[:do] || 0).to_f
    ref_weight = (weight[:ref] || 0).to_f
    value_weight = (weight[:value] || 0).to_f
    
    total_weight = block_weight + do_weight + ref_weight + value_weight
    
    do_start = (block_weight) / total_weight
    ref_start = (block_weight + do_weight) / total_weight
    value_start = (block_weight + do_weight + ref_weight) / total_weight
    
    @block = 0...do_start
    @do = do_start...ref_start
    @ref = ref_start...value_start
  end
  
  def float_range (range)
    @min_float, @max_float = [range.begin, range.end].sort
  end
  
  def int_range (range)
    @min_int, @max_int = [range.begin, range.end].sort
  end
  
  def generate_block (remaining_depth)
    points = (0...@block_width).collect do
      case rand
        when @block then generate_block(remaining_depth - 1) if remaining_depth > 0
        when @do    then "do #{@do_instructions.shuffle.first}"
        when @ref   then "ref #{@ref_names.shuffle.first}"
        else generate_value
      end
    end
    
    points.length > 1 ? ["block {", points.compact, "}"].join(" ") : points
  end
  
  def generate_value (value_type = nil)
    unless value_type
      value_types = @value_types + @code_type_switch
      return unless value_type = value_types.shuffle.first
    end
    
    @footnotes_needed << value_type
    "value «#{value_type}»"
  end
  
  def generate_footnotes
    footnotes = []
    code_recursion, *code_type_switch = @code_recursion, *@code_type_switch
    
    while value_type = @footnotes_needed.pop
      value_string = case value_type
        when :bool       then rand < 0.5
        when :float      then rand(@max_float - @min_float).to_f + @min_float
        when :int        then rand(@max_int - @min_int).to_i + @min_int
        when :proportion then rand
        when :code
          @code_type_switch.delete(:code) unless (@code_recursion -= 1) >= 0
          generate_block(@block_depth)
      else
        NudgeValue::TYPES[value_type].random
      end
      
      footnotes << "«#{value_type}»#{value_string}"
    end
    
    @code_recursion, *@code_type_switch = code_recursion, *code_type_switch
    footnotes.join("\n")
  end
end
