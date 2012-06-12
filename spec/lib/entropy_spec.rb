require 'spec_helper.rb'
require './lib/entropy.rb'
require './lib/sample.rb'

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
      (1..5).each { |i| Factory(:sample, value: 2) }
      (1..3).each { |i| Factory(:sample, value: 5) }
    end
    
    it 'should load the distribution' do
      @entropy.load_distribution
      @entropy.distribution.should == {2 => 5, 5 => 3}
    end
  end
end