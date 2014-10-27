source 'https://rubygems.org'

gem "rails", "3.2.19"
gem "mysql2", "~> 0.3.13"
gem "dalli", "~> 2.7.0"
gem "countries", "~> 0.9.2"

gem "sass-rails",   "~> 3.2.5"
gem "coffee-rails", "~> 3.2.2"
gem "therubyracer", "~> 0.12.0", :require => "v8"
gem "uglifier", "~> 2.4.0"
gem "jquery-rails", "~> 3.1.0"
gem 'jquery-ui-rails', '~> 5.0.0'
gem 'slim-rails'
gem 'exception_notification', '~> 4.0.1'
gem 'httparty', '~> 0.13.1'
gem 'faraday'
gem 'faraday_middleware'
gem "bower-rails", "~> 0.9.1"

group :development do
  gem 'rubocop'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano-rails', '~> 1.1.1', require: false
  gem 'capistrano-bundler', '~> 1.1.2', require: false
end

group :test do
  gem 'capybara-screenshot'
  gem "simplecov", require: false
  gem 'timecop'
  gem 'poltergeist'
  gem 'capybara'
  gem "webmock"
  gem "codeclimate-test-reporter", require: false
  gem "vcr"
end

group :test, :development do
  gem "rspec-rails", "~> 2.14.0"
  gem "brakeman", :require => false
end
