require 'spec_helper.rb'
require 'base_sample.rb'

describe BaseSample do
  before :each do
    (1..10).each { |i| Factory(:sample, value: i) }
    @sample = BaseSample.new
    @node = mock('BaseNode')
    @node.stub!(:id).and_return(rand(1e9))
    @node.stub!(:degree)
  end 
  
  describe "count" do
    it 'Should return a count of 10' do
      @sample.count.should == 10
    end
    
    it 'Should increment count by 1' do
      @sample.save!(@node) { |n| rand(1e9) }
      @sample.count.should == 11
    end
  end
  
  describe "save!" do
    before :each do
      @zsample = {node: @node.id, value: 12.0, monitor: 1.0} 
      @sample.stub!(:z_statistic).and_return(@zsample[:monitor])
      @sample.save!(@node) { |n| @zsample[:value] }
    end
    
    %w(node value monitor).each do |attr|
      it "should have #{attr}" do
        Sample.last.send(attr.to_sym).to_s.should == @zsample[attr.to_sym].to_s 
      end
    end
  end
  
  describe "last_node" do
    it 'should return the node id of the last node sampled' do
      @sample.save!(@node) { |n| 42}
      @sample.last_node.should == @node.id
    end
  end
end
