require 'spec_helper.rb'
require 'markov_chain.rb'

describe MarkovChain do
  describe 'next' do
    before :each  do
      @candidate_node = mock(:BaseNode)
      @current_node = mock(:BaseNode)
      @mc = MarkovChain.new
      @mc.stub!(:select_candidate).and_return(@candidate_node)
    end
    it 'should return the candidate node' do
      @mc.stub!(:acceptance_probability).and_return(1)
      @mc.next(@current_node).should == @candidate_node
    end
    
    it 'should return the current node' do
      @mc.stub!(:acceptance_probability).and_return(0)
      @mc.next(@current_node).should == @current_node
    end
  end
end
