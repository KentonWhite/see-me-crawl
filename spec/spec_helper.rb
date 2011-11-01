require 'data_mapper'
require 'fakeweb'

# DataMapper.setup(:default, adapter: 'sqlite3', database: '::memory')   

RSpec.configure do |config|
  config.before(:all) do
    FakeWeb.allow_net_connect = false
    DataMapper.setup(:default, adapter: 'sqlite3', database: ':memory:') 
  end

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  config.after(:each) do
  end
end