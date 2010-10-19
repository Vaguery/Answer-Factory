# describe "causes rspec-2.0.1 to hang when running from command line under ruby 1.9.2-p0: " do
#   it "this sets up the problem" do
#     class String
#       # alias :to_int :to_i  # comment this out to silence the problem
#     end 
#   end
#   
#   it "hangs when you raise an exception" do
#     raise "x"
#   end
#   
#   it "silently passes specs that contain code without matchers" do
#     2+3
#   end
#   
#   
#   it "does fine with matchers" do
#     1.should == 1
#   end
#   
#   it "glides right by empty specs" do
#     # nothing at all
#   end
# end