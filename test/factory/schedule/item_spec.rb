require 'answer_factory'

describe "Schedule::Item" do
  describe ".new (limit: Fixnum, component: Object)" do
    it "sets the component and the limit of the new Schedule::Item" do
      a = mock(:a)
      
      item = Schedule::Item.new(1, a)
      
      item.instance_variable_get(:@component).should === a
      item.instance_variable_get(:@limit).should === 1
    end
  end
end
