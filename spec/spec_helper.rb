require 'data_mapper'
require 'fakeweb'
require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
 config.before(:all) do
    FakeWeb.allow_net_connect = false
    DataMapper.setup(:default, adapter: 'sqlite3', database: ':memory:') 
    DataMapper.setup(:local, adapter: 'sqlite3', database: ':memory:') 
  end

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  config.after(:each) do
  end
end