require 'spec_helper.rb'
require 'z_sample.rb'

describe ZSample do
  before :each do
    (1..10).each { |i| Factory(:base_sample, value: i) }
    @sample = ZSample.new
    @node = mock('BaseNode')
    @node.stub!(:id).and_return(rand(1e9))
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
      @zsample = {node: @node.id, value: 12.0, monitor: 10.0} 
      @sample.stub!(:z_statistic).and_return(@zsample[:monitor])
      @sample.save!(@node) { |n| @zsample[:value] }
    end
    
    %w(node value monitor).each do |attr|
      it "should have #{attr}" do
        DataMapper.repository(:local) do  
          BaseSample.last.send(attr.to_sym).to_s.should == @zsample[attr.to_sym].to_s 
        end
      end
    end
  end
  
  describe "last_node" do
    it 'should return the node id of the last node sampled' do
      @sample.save!(@node) { |n| 42}
      @sample.last_node.should == @node.id
    end
  end
  
  describe "converged?" do
    it 'should return false because count is less then min_iterations' do
      @sample.converged?.should == false
    end 
    
    it 'should return false because monitor is not in acceptance range' do
      @sample = ZSample.new(5)
      @sample.converged?.should == false
    end
    
    it 'should return false when there is no data' do
      DataMapper.auto_migrate!
      @sample = ZSample.new
      @sample.converged?.should == false
    end
    
    it 'should return true because monitor is in acceptance range' do
      DataMapper.auto_migrate!
      (1..10).each { |i| Factory(:base_sample, monitor: 0) }
      @sample = ZSample.new(5)
      @sample.converged?.should == true
    end
    
    it 'should return false because count is less the min_interactions, even though monitory is in acceptance range' do
      DataMapper.auto_migrate!
      (1..10).each { |i| Factory(:base_sample, monitor: 0) }
      @sample = ZSample.new(100)
      @sample.converged?.should == false      
    end
  end
  
  describe "expectation_value" do
    it 'should return the mean of the last half values (8.0)' do
      @sample.expectation_value.should == 8.0
    end
  end
  
  describe 'z_statistic' do
    it 'should return a z_statistic for the values (1..10) (-4.949747468305833)' do
      @sample.send(:z_statistic).should == -4.949747468305833      
    end
    
    it 'should return 0 if there are no samples' do
      DataMapper.auto_migrate!
      @sample.send(:z_statistic).should == 0.0
    end
    
    it 'should return 0 if there is only 1 sample' do
      DataMapper.auto_migrate!
      Factory(:base_sample)
      @sample.send(:z_statistic).should == 0.0
    end
  end
end