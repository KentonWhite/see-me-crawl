require 'spec_helper' 
require 'metropolis_hastings_markov_chain'

describe MetropolisHastingsMarkovChain do
  describe 'acceptance_probability' do
    before :each do
      @mc = MetropolisHastingsMarkovChain.new
      @high_degree = mock(:HighDegreeNode)
      @low_degree = mock(:LowDegreeNode)
      @high_degree.stub!(:degree).and_return(10)
      @low_degree.stub!(:degree).and_return(1)
    end
    it 'should return a probabilty of 1' do
      current_node = @high_degree
      candidate_node = @low_degree
      @mc.acceptance_probability(current_node, candidate_node).should == 1.0
    end
    
    it 'should return a probability of 0.1' do
      current_node = @low_degree
      candidate_node = @high_degree
      @mc.acceptance_probability(current_node, candidate_node).should == 0.1      
    end
    
  end  
end