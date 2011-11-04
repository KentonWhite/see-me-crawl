require 'spec_helper'
require 'twitter_node'
require 'graph'

describe TwitterNode do

  before :each do
    vcr_config 'twitter'
  end
   
  describe 'new' do
    before :each do
      @id = 16450138
      VCR.use_cassette('new', record: :new_episodes) { @node = TwitterNode.new(@id) }
    end
    it 'should load a node from Twitter' do
      p @node.in_degree
      @node.in_degree.should == 1881
    end
    
    it 'should save the node the DB' do
      Node.first(id: @id).should_not == nil
    end
    
    it 'should load the node from the DB' do
      DataMapper.auto_migrate!
      in_degree = 42
      Factory(:node, id: @id, in_degree: in_degree)
      VCR.use_cassette('new', record: :new_episodes) { @node = TwitterNode.new(@id) }
      @node.in_degree.should == in_degree
    end
  end
end