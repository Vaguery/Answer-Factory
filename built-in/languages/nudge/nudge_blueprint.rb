# encoding: UTF-8
class NudgeBlueprint < Blueprint
  def language
    :Nudge
  end
  
  def points
    NudgePoint.from(self).points
  end
  
  def blending_crossover (other)
    tree_a = NudgePoint.from(self)
    tree_b = NudgePoint.from(other)
    
    a_top_level_points = tree_a.is_a?(BlockPoint) ? tree_a.instance_variable_get(:@points) : [tree_a]
    b_top_level_points = tree_b.is_a?(BlockPoint) ? tree_b.instance_variable_get(:@points) : [tree_b]
    
    available_points = a_top_level_points + b_top_level_points
    n = Random.rand(available_points.length) + 1
    
    tree = BlockPoint.new(*available_points.sample(n))
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def delete_n_points_at_random (n)
    tree = NudgePoint.from(self)
    
    n.times do
      n_of_deletion = Random.rand(tree.points - 1) + 1
      tree.delete_point_at(n_of_deletion)
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def insert_n_points_at_random (n, writer)
    tree = NudgePoint.from(self)
    
    n.times do
      n_of_insertion = Random.rand(tree.points - 1) + 1
      tree.insert_point_after(n_of_insertion, writer.random)
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def mutate_n_points_at_random (n, writer)
    tree = NudgePoint.from(self)
    
    i_of_mutation = Random.rand(tree_points ||= tree.points)
    mutation = NudgePoint.from(writer.random)
    
    if i_of_mutation == 0
      tree = mutation
    else
      tree.replace_point_at(i_of_mutation, mutation)
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def mutate_n_values_at_random (n, writer)
    tree = NudgePoint.from(self)
    
    if value_type = tree.instance_variable_get(:@value_type)
      tree = NudgePoint.from(writer.random_value(value_type))
    else
      value_point_indices = (1...tree.points).collect do |i|
        point = tree.get_point_at(i)
        [i, value_type] if value_type = point.instance_variable_get(:@value_type)
      end.compact
      
      n.times do
        i, value_type = value_point_indices.pop
        break unless i
        
        new_value_point = NudgePoint.from(writer.random_value(value_type))
        tree.replace_point_at(i, new_value_point)
      end
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def point_crossover (other)
    tree_a = NudgePoint.from(self)
    tree_b = NudgePoint.from(other)
    
    n_of_a = Random.rand(tree_a.points)
    n_of_b = Random.rand(tree_b.points)
    
    if n_of_a != 0 && n_of_b != 0
      point_a = tree_a.get_point_at(n_of_a)
      point_b = tree_b.replace_point_at(n_of_b, point_a)
      tree_a.replace_point_at(n_of_a, point_b)
    elsif n_of_a == 0 && n_of_b != 0
      tree_a = tree_b.replace_point_at(n_of_b, tree_a)
    elsif n_of_a != 0 && n_of_b == 0
      tree_b = tree_a.replace_point_at(n_of_a, tree_b)
    end
    
    blueprint_c = NudgeBlueprint.new(tree_a.to_script)
    blueprint_d = NudgeBlueprint.new(tree_b.to_script)
    
    [blueprint_c, blueprint_d]
  end
  
  def unwrap_block
    tree = NudgePoint.from(self)
    
    if points = tree.instance_variable_get(:@points)
      blocks = []
      
      points.each_with_index do |point, i|
        blocks << [point, i] if point.is_a?(BlockPoint)
      end
      
      block, index = blocks.sample
      
      points[index..index] = block.instance_variable_get(:@points) if block
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
  
  def wrap_block
    tree = NudgePoint.from(self)
    
    if points = tree.instance_variable_get(:@points)
      block_start, block_end = [Random.rand(points.length), Random.rand(points.length)].sort
      
      unless block_start == block_end
        block = BlockPoint.new(*points.slice!(block_start..block_end))
        points[block_start...block_start] = block
      end
    end
    
    NudgeBlueprint.new(tree.to_script)
  end
end
