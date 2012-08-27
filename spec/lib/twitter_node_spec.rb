require 'spec_helper'
require 'twitter_node'
require 'graph'
require 'chronic'

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
    
    it 'should load the node from Twitter' do
      DataMapper.auto_migrate!
      in_degree = 42 
      visited_at = Chronic.parse('1 month ago')
      Factory(:node, id: @id, in_degree: in_degree, visited_at: visited_at)
      VCR.use_cassette('new', record: :new_episodes) { @node = TwitterNode.new(@id) }
      @node.in_degree.should == 1881     
    end
  end
  
  describe 'fetch' do
    before :each do
      @id = 16450138
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node = TwitterNode.new(@id)
      end
    end

    it 'should fetch friends from twitter' do
      VCR.use_cassette('fetch', record: :new_episodes) do
        @friends = @node.fetch(:friends)
      end 
      @friends.sort!.first.should == 12
    end

    it 'should fetch followers from twitter' do 
      VCR.use_cassette('fetch', record: :new_episodes) do
        @friends = @node.fetch(:followers)
      end 
      @friends.sort!.first.should == 3382    
    end
  end
  
  describe 'crawl!' do
    before :each do
      @id = 16450138
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node = TwitterNode.new(@id)
      end
    end
    
    it 'should crawl all nodes' do
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node.crawl!
      end
      @node.friends.size.should == 2053      
    end
    
    it 'should not crawl private nodes' do
      @node.instance_variable_set(:@private, true)
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node.crawl!
      end
      @node.friends.size.should == 0      
    end
    
    it 'should not crawl recently crawled nodes' do
      @node.instance_variable_set(:@crawled_at, DateTime.now)
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node.crawl!
      end
      @node.friends.size.should == 0      
    end

    it 'should  crawl stale  nodes' do
      @node.instance_variable_set(:@crawled_at, Chronic.parse("1 month ago").to_datetime)
      VCR.use_cassette('fetch', record: :new_episodes) do
        @node.crawl!
      end
      @node.friends.size.should == 2053     
    end
    
  end
end