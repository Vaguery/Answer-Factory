# won't hurt to sketch the search definition DSL, too

minimize "point count" do
  before running do
    measure :code_points from My.code.points
  end
end


minimize "average NOOPs encountered" do
  after running(:each) do
    collect @NOOPs from My.NOOPs
  end
  
  measure :avg_NOOPs as @NOOPs.mean
end


minimize "maximum absolute deviation" do
  after running(:each) do
    collect @absDiffs from My.absDiff
  end
  
  measure :max_deviation as @absDiffs.max
end