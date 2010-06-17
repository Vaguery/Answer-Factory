require 'answer_factory'

describe "Schedule::TimedRun" do
  describe "#run" do
    it "repeatedly calls #run on its component until the allotted time expires" do
      a = mock(:a)
      t = Time.now
      limit = 0.1
      
      a.stub!(:name)
      a.should_receive(:run).at_least(10).times
      
      Schedule::TimedRun.new(limit, a).run
      
      (t + limit < Time.now).should === true
    end
  end
end
