source :rubygems

gem 'sqlite3-ruby', '~>1.3.0', :require => 'sqlite3'
gem 'dm-adapter-simpledb', '~>1.5.0'

group :devlopment do
  gem 'rspec', '~>2.0.0'
  gem 'guard', '~>0.8.0'
  gem 'rb-inotify', '~>0.8.0', :require => false
  gem 'rb-fchange', '~>0.0.0', :require => false
  gem 'guard-rspec'
  gem 'guard-bundler'

  if RUBY_PLATFORM.downcase.include?("darwin")
    gem 'rb-fsevent', '~>0.4.0', :require => false
    gem 'growl_notify', '~>0.0.0' 
  end
end