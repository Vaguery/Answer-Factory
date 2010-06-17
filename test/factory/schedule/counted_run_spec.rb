require 'answer_factory'

describe "Schedule::CountedRun" do
  describe "#run" do
    it "calls #run on its component the designated number of times" do
      a = mock(:a)
      
      a.stub!(:name)
      a.should_receive(:run).exactly(5).times
      
      Schedule::CountedRun.new(5, a).run
    end
  end
end
