require 'data_mapper'
require 'fakeweb'
require 'factory_girl' 
require 'vcr'
require 'chronic'

FactoryGirl.find_definitions
FakeWeb.allow_net_connect = false

RSpec.configure do |config|
 config.before(:all) do
    DataMapper.setup(:default, adapter: 'sqlite3', database: ':memory:') 
    DataMapper.setup(:local, adapter: 'sqlite3', database: ':memory:') 
    DataMapper.auto_migrate!
  end

  config.before(:each) do
  end

  config.after(:each) do
    DataMapper.auto_migrate!
  end
end  

def vcr_config(dir_name)
  VCR.config do |c|
    c.cassette_library_dir = "spec/fixtures/#{dir_name}"
    c.stub_with :fakeweb # or :webmock
    c.default_cassette_options = {:record => :none}
  end 
end
