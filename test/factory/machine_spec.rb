require 'answer_factory'

W = Workstation.new(:w)
X = Workstation.new(:x)

describe "Machine" do
  describe ".new (name: Symbol, workstation: Workstation|Symbol)" do
    it "accepts either a workstation object or the symbol name of an existing workstation" do
      lambda do
        m1 = Machine.new(:m1, W)
        m2 = Machine.new(:m2, :w)
      end.should_not raise_error
    end
    
    it "cannot create a machine for a nonexistent workstation" do
      lambda { Machine.new(:m, :no_such_workstation) }.should raise_error ArgumentError,
        "cannot create machine for nonexistent workstation :no_such_workstation"
    end
    
    it "stores the new machine in the workstation's components" do
      m = Machine.new(:m, W)
      
      W.instance_variable_get(:@components)[:m].should == m
    end
    
    it "calls #defaults on the created machine" do
      m = Machine.new(:m, W)
      
      m.should_receive(:defaults)
      m.send(:initialize, :m, W)
    end
    
    describe "{|m| config }" do
      it "evaluates the configuration block, passing the created machine as m" do
        m = Machine.new(:m, W)
        
        m.should_receive(:object_id)
        m.send(:initialize, :m, W) {|m| m.object_id }
      end
    end
  end
  
  describe "#run" do
    it "begins by emptying out the answers_by_machine array for this machine" do
      m = Machine.new(:m, W)
      
      W.instance_variable_set(:@answers_by_machine, {:m => [1,2,3]})
      
      m.stub!(:process)
      m.run
      
      W.instance_variable_get(:@answers_by_machine)[:m].empty?.should == true
    end
    
    it "calls #process, with an array of this machine's answers as its argument" do
      m = Machine.new(:m, W)
      
      W.instance_variable_set(:@answers_by_machine, {:m => [1,2,3]})
      
      m.should_receive(:process).with([1, 2, 3])
      m.run
    end
  end
  
  describe "#process (answers: Array)" do
    it "sends all of its answers back to the answers_by_machine array by default" do
      m = Machine.new(:m, W)
      
      W.instance_variable_set(:@answers_by_machine, Hash.new {|hash, key| hash[key] = [] })
      
      m.process([1,2,3])
      
      W.instance_variable_get(:@answers_by_machine)[:m].should == [1,2,3]
    end
  end
  
  describe "#send_answer (answer: Answer, destination: Machine|Symbol|Array)" do
    it "does nothing if answer is nil" do
      m = Machine.new(:m, W)
      
      m.should_receive(:send_answers).exactly(0).times
      
      m.send_answer(nil, m)
    end
    
    it "calls #send_answers with the destination and a one-element array containing the given answer as its arguments" do
        m = Machine.new(:m, W)
        a = mock(:a)
        
        m.should_receive(:send_answers).with([a], m)
        
        m.send_answer(a, m)
    end
  end
  
  describe "#send_answers" do
    describe "(answers: Array, destination: Machine)" do
      it "adds the answers to the destination machine's answers_by_machine array" do
        m = Machine.new(:m, W)
        a = mock(:a)
        answers = [a]
        
        W.instance_variable_set(:@answers_by_machine, Hash.new {|hash, key| hash[key] = [] })
        
        m.send_answers(answers, m)
        
        W.instance_variable_get(:@answers_by_machine)[:m].should == answers
      end
    end
    
    describe "(answers: Array, destination: Symbol)" do
      it "adds the answers to the answers_to_be_saved array" do
        m = Machine.new(:m, W)
        a = mock(:a)
        answers = [a]
        
        a.stub!(:workstation_name=)
        a.stub!(:machine_name=)
        a.stub!(:locked=)
        
        W.instance_variable_set(:@answers_to_be_saved, [])
        
        m.send_answers(answers, :x)
        
        W.instance_variable_get(:@answers_to_be_saved).should == answers
      end
      
      it "relocates the answers to the correct workstation" do
        m = Machine.new(:m, W)
        answers = [1,2,3]
        
        W.instance_variable_set(:@answers_to_be_saved, [])
        
        Answer.should_receive(:relocate).with(answers, :x, nil)
        
        m.send_answers(answers, :x)
      end
    end
    
    describe "(answers: Array, destination: Array)" do
      describe "- local machine" do
        it "adds the answers to the designated answers_by_machine array" do
          m = Machine.new(:m, W)
          a = mock(:a)
          answers = [a]
          
          W.instance_variable_set(:@answers_by_machine, Hash.new {|hash, key| hash[key] = [] })
          
          m.send_answers(answers, [:w, :m])
          
          W.instance_variable_get(:@answers_by_machine)[:m].should == answers
        end
      end
      
      describe "- external machine" do
        it "adds the answers to the answers_to_be_saved array" do
          m = Machine.new(:m, W)
          a = mock(:a)
          answers = [a]
          
          a.stub!(:workstation_name=)
          a.stub!(:machine_name=)
          a.stub!(:locked=)
          
          W.instance_variable_set(:@answers_to_be_saved, [])
          
          m.send_answers(answers, [:x, :m])
          
          W.instance_variable_get(:@answers_to_be_saved).should == answers
        end
        
      it "relocates the answers to the correct workstation and machine" do
        m = Machine.new(:m, W)
        answers = [1,2,3]
        
        W.instance_variable_set(:@answers_to_be_saved, [])
        
        Answer.should_receive(:relocate).with(answers, :x, :m)
        
        m.send_answers(answers, [:x, :m])
      end
      end
    end
  end
end
