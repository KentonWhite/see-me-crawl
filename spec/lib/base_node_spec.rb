require 'spec_helper'
require 'base_node'

describe BaseNode do
  before :each do
    max_node = 1e9
    @id = rand(max_node)
    @node = BaseNode.new(@id)
  end
  describe 'id' do
    it 'should return the node id' do
      @node.id.should == @id
    end 
    
  end
  
  describe 'degree' do
    it 'should return a degree of 0' do
      @node.degree.should == 0
    end
    
    it 'should return a degree of 10' do
      Factory(:node, id: @id, in_degree: 2, out_degree: 8)
      @node = BaseNode.new(@id)
      @node.degree.should == 10
    end
  end
  
  describe 'private?' do
    it 'should return nil' do
      @node.private?.should == nil
    end

    it 'should return false' do
      Factory(:node, id: @id, private: false)
      @node = BaseNode.new(@id)
      @node.private?.should == false
    end
    
    it 'should return true' do
      Factory(:node, id: @id, private: true)
      @node = BaseNode.new(@id)
      @node.private?.should == true
    end
  end
  
  describe 'connections' do
    it 'should return []' do
      node = BaseNode.new(rand(1e9))
      node.connections.should == []
    end
    
    it 'should return 2 nodes' do
      id = rand(1e9)
      n1 = rand(1e9)
      n2 = rand(1e9)
      Factory(:edge, n1: id, n2: n2)
      Factory(:edge, n1: n1, n2: id)
      node = BaseNode.new(id)
      node.connections.sort!.should == [n1, n2].sort!
    end
    
    it 'should return the same node twice' do
      id = rand(1e9)
      n = rand(1e9)
      Factory(:edge, n1: id, n2: n)
      Factory(:edge, n1: n, n2: id)
      node = BaseNode.new(id)
      node.connections.should == [n, n]      
    end
  end
  
  describe 'friends' do
    it 'should return []' do
      node = BaseNode.new(rand(1e9))
      node.friends.should == []
    end
    
    it 'should return 2 nodes' do
      id = rand(1e9)
      n1 = rand(1e9)
      n2 = rand(1e9)
      Factory(:edge, n1: id, n2: n1)
      Factory(:edge, n1: id, n2: n2)
      node = BaseNode.new(id)
      node.friends.sort!.should == [n1,n2].sort!
    end 
  end
  
  describe 'followers' do
    it 'should return []' do
      node = BaseNode.new(rand(1e9))
      node.followers.should == []
    end                          
    
    it 'should return 2 nodes' do
      id = rand(1e9)
      n1 = rand(1e9)
      n2 = rand(1e9)
      Factory(:edge, n1: n1, n2: id)
      Factory(:edge, n1: n2, n2: id)
      node = BaseNode.new(id)
      node.followers.sort!.should == [n1,n2].sort!      
    end
  end 
  
  describe 'new_node' do
    it 'should return a new basenode' do
      node = BaseNode.new(rand(1e9))
      node.new_node(rand(1e9)).class.should == node.class
    end
  end
end