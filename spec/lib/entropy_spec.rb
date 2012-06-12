require 'spec_helper.rb'
require './lib/entropy.rb'
require './lib/sample.rb'
require './lib/graph.rb'
require './lib/base_node'

describe Entropy do
  before :each do
    @entropy = Entropy.new
  end
  
  describe 'distribution' do
    it 'should have an attribute distribution, which is a hash' do
      @entropy.distribution.should be_a_kind_of(Hash)
    end
  
    it 'should default to 0' do
      @entropy.distribution[3].should == 0
    end
    
    it 'should be settable' do
      @entropy.distribution[3] = 100
      @entropy.distribution[3].should == 100
    end
  end
  
  describe 'load' do
    before :each do
      (1..5).each { |i| Factory(:sample, degree: 2) }
      (1..3).each { |i| Factory(:sample, degree: 5) }
    end
    
    it 'should load the distribution' do
      @entropy.load_distribution
      @entropy.distribution.should == {2 => 5, 5 => 3}
    end
  end
  
  describe 'add_node' do
    before :each do
      @node = BaseNode.new(Factory(:node).id)
      @entropy.add_node @node
    end
    it 'should add a node to the distribution' do
      @entropy.distribution[@node.degree].should == 1
    end
    
    it 'should update the total degree' do
      @entropy.total_degree.should == @node.degree
    end
  end
  
  describe 'total_degree' do
    before :each do
      (1..5).each { |i| Factory(:sample, degree: 2) }
      (1..3).each { |i| Factory(:sample, degree: 5) }
      @entropy = Entropy.new
    end
    
    it 'should return a total degree of 25' do
      @entropy.total_degree.should == 25
    end
  end
  
  describe 'q' do
    before :each do
      (1..5).each { |i| Factory(:sample, degree: 2) }
      (1..3).each { |i| Factory(:sample, degree: 5) }
      @entropy = Entropy.new
    end 
    
    it 'should return a q value for the degree value' do
      @entropy.q(5).should == 0.6
    end   
  end
  
  describe 'entropy' do
    before :each do
      (1..5).each { |i| Factory(:sample, degree: 2) }
      (1..3).each { |i| Factory(:sample, degree: 5) }
      @entropy = Entropy.new
    end 
    
    it 'should return the entropy of the sampled graph' do
      @entropy.entropy.round(9).should == 0.673011667
    end
  end
end