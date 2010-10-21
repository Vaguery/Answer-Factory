require File.dirname(__FILE__) + '/../../spec_helper'

describe ScoreLength do
  before(:each) do
    grab_answer = Answer.new(mock('grab', {
      :language => 'grab',
      :force_encoding => true,
      :length => 20
    }))
    grab_answer.stub!(:id, 5)
    
    nudge_answer_1 = Answer.new(mock('nudge 1', {
      :language => 'nudge',
      :force_encoding => true,
      :length => 5
    }))
    nudge_answer_1.stub!(:id, 6)
    
    nudge_answer_2 = Answer.new(mock('nudge 2', {
      :language => 'nudge',
      :force_encoding => true,
      :length => 50
    }))
    nudge_answer_2.stub!(:id, 7)
    
    answers = [grab_answer, nudge_answer_1, nudge_answer_2]
    @scorer = ScoreLength.new(answers)
  end
  
  describe "scoring" do
    it "scores each answer on length" do
      pending
    end
  end
end