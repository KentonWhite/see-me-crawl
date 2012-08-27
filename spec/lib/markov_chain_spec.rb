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

  describe 'select_candidate' do
    before :each do
      @mc = MarkovChain.new
      @current_node = mock(:BaseNode)
      @public_node = mock(:PublicNode)
      @public_node.stub!(:private?).and_return(false)
      @private_node = mock(:PrivateNode)
      @private_node.stub!(:private?).and_return(true)
      nodes = (1..10).map { @private_node }
      nodes << @public_node 
      @current_node.stub!(:connections).and_return(nodes)
      @current_node.stub!(:new_node).with(@public_node).and_return(@public_node)
      @current_node.stub!(:new_node).with(@private_node).and_return(@private_node) 
    end 
    
    it 'should return a node object' do
      @mc.select_candidate(@current_node).class.should == @current_node.class
    end

    it 'should select public node' do
      @mc.select_candidate(@current_node).should == @public_node
    end 

    it 'should not select private node' do
      @mc.select_candidate(@current_node).should_not == @private_node
    end

    it 'should throw an error' do
      @current_node.stub!(:connections).and_return([])
      expect { @mc.select_candidate(@current_node) }.to raise_error(MarkovChain::NoValidNextNode)
    end
  end
  
  describe 'acceptance_probability' do
    it 'should raise an error' do
      @mc = MarkovChain.new
      expect { @mc.acceptance_probability(mock(:BaseNode), mock(:BaseNode)) }.to raise_error(MarkovChain::MethodNotImplemented)
    end
  end
end
