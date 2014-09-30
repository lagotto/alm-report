source "https://rubygems.org"

gem "rails", "4.1.6"
gem "mysql2"
gem "dalli"
gem "countries"

gem "sass-rails"
gem "coffee-rails"
gem "therubyracer"
gem "uglifier"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "slim-rails"
gem "exception_notification"
gem "httparty"
gem "faraday"
gem "faraday_middleware"

group :development do
  gem "rubocop"
  gem "pry-rails"
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano-rails", require: false
  gem "capistrano-bundler", require: false
end

group :test do
  gem "capybara-screenshot"
  gem "simplecov", require: false
  gem "timecop"
  gem "poltergeist"
  gem "capybara"
  gem "webmock"
  gem "codeclimate-test-reporter", require: false
end

group :test, :development do
  gem "rspec-rails"
  gem "brakeman", :require => false
end
