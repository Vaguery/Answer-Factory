require 'racc/parser'
require 'strscan'

class Score < Racc::Parser
  def Score.to_string (hash)
    hash.collect {|k,v| "#{k}:#{v}" }.join
  end
  
  def Score.from (string)
    Score.new(string).send(:do_parse)
  end
  
  def initialize (string)
    @tokens = tokenize(string)
  end
  
  def tokenize (string)
    ss = StringScanner.new(string)
    tokens = []
    
    until ss.eos?
      tokens << case
        when ss.scan(/([a-zA-Z_][a-zA-Z0-9_]*):/)         then [:KEY, ss[1].intern]
        when ss.scan(/-?[0-9]+\.[0-9]+(?:e[+-][0-9]+)?/)  then [:FLOAT, ss.matched.to_f]
        when ss.scan(/-?[0-9]+/)                          then [:INT, ss.matched.to_i]
      end
    end
    
    tokens << [false, 0]
  end
  
  def next_token
    @tokens.shift
  end
   
  def new_empty_hash (*)
    {}
  end
  
  def new_hash (v, *)
    { v[0][0] => v[0][1] }
  end
  
  def add_score (v, *)
    v[0][v[1][0]] = v[1][1]
    v[0]
  end
  
  def tmp_score (v, *)
    [v[0], v[1]]
  end
  
  def tmp_value (v, vv, value)
    value
  end
  
  Racc_debug_parser = false
  Racc_arg = [
    [7,1,1,4,5,9],
    [2,0,2,1,1,7],
    [-1,-7,-7,-2,-5,-6,-4,-7,-3,10],
    [-1,0,0,nil,nil,nil,nil,5,nil,nil],
    [3,2,8,6],
    [2,1,2,3],
    [nil,nil,nil,nil],
    [nil,1,0,2],
    5,
    [ 0, 0, :racc_error, 0, 6, :new_empty_hash, 1, 6, :new_hash, 2, 6, :add_score, 2, 7, :tmp_score, 1, 8, :tmp_value, 1, 8, :tmp_value ],
    { false => 0, Object.new => 1, :KEY => 2, :FLOAT => 3, :INT => 4 },
    10,
    7,
    true
  ]
end
