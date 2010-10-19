require File.dirname(__FILE__) + '/../spec_helper'

describe "Answer" do
  before(:all) do
    Factory::Infinity = 12
  end
  
  after(:all) do
    Factory.send(:remove_const, :Infinity)
  end
  
  before(:each) do
    @blueprint = FakeBlueprint.new
    @answer = Answer.new(@blueprint)
  end
  
  it 'obtains its language from the language of its blueprint' do
    @answer.language.should == :Fake
  end
  
  describe 'score values' do
    it 'retrived by name if score exists' do
      @answer.instance_variable_set("@scores", {:awesomeness => Score.new('awesomeness', 5, 0)})
      @answer.score(:awesomeness).should == 5
    end
    
    it 'default to Factory::Infinity if there is no score by that name' do
      @answer.score(:awesomeness).should == Factory::Infinity
    end
  end
  
  describe 'dominated state' do
    before(:each) do
      @best_at_running = Score.new('running', 1, nil)
      @middle_at_running = Score.new('running', 5, nil)
      @worst_at_running = Score.new('running', 10, nil)
      
      @best_at_swimming = Score.new('swimming', 1, nil)
      @middle_at_swimming = Score.new('swimming', 10, nil)
      @worst_at_swimming = Score.new('swimming', 20, nil)
      
      @best_at_biking = Score.new('biking', 4, nil)
      @middle_at_biking = Score.new('biking', 20, nil)
      @worst_at_biking = Score.new('biking', 100, nil)
    end
    
    it 'is dominated if any of the compared answer\'s scores for any listed criteria is better' do
      another_answer = Answer.new(@blueprint)
      another_answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @best_at_swimming
      })
      
      @answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @middle_at_swimming
      })
      
      @answer.nondominated_vs?(another_answer, [:swimming,:running]).should == false
    end
    
    it 'is non-dominated if all scores of the comapred answer for all listed criteria are worse' do
      another_answer = Answer.new(@blueprint)
      another_answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @middle_at_swimming
      })
      
      @answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @best_at_swimming
      })
      
      @answer.nondominated_vs?(another_answer, [:running,:swimming]).should == true
    end
  
    it 'is non-dominated if all scores of the comapred answer are worse for listed criteria even if unlisted criteria are better' do
      another_answer = Answer.new(@blueprint)
      another_answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @middle_at_swimming,
        :biking => @best_at_biking,
      })
      
      @answer.instance_variable_set("@scores", {
        :running => @middle_at_running,
        :swimming => @best_at_swimming,
        :biking => @worst_at_biking
      })
      
      @answer.nondominated_vs?(another_answer, [:running,:swimming]).should == true
    end
  end
  
  describe 'assigning to a location' do

    it 'sets the location' do
      @answer.assign('somewhere')
      @answer.location.should == 'somewhere'
    end
    
    it 'returns the answer' do
      @answer.assign('somewhere').should == @answer
    end
  end
end