require 'spec_helper'

require "simplecov"
# SimpleCov.start do
#   add_filter "/vendor/"
# end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

# set ENV variables for testing
ENV["RAILS_ENV"] ||= 'test'
ENV["OMNIAUTH"] = "cas"
ENV["CAS_URL"] = "https://register.example.org"
ENV["CAS_INFO_URL"] = "http://example.org/users"
ENV["CAS_PREFIX"]= "/cas"

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

WebMock::Config.instance.query_values_notation = :flat_array
WebMock.disable_net_connect!(
  allow: ['codeclimate.com', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    timeout: 180,
    inspector: true
  })
end

Capybara.javascript_driver = :poltergeist

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes_" + ENV["SEARCH"]
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.filter_sensitive_data("<API_KEY>") { ENV["ALM_API_KEY"] }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # ## Mock Framework

  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  OmniAuth.config.test_mode = true
  config.before(:each) do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      provider: ENV["OMNIAUTH"],
      uid: "12345",
      info: { "email" => "joe_#{ENV["OMNIAUTH"]}@example.com",
              "name" => "Joe Smith" },
      extra: { "email" => "joe_#{ENV["OMNIAUTH"]}@example.com",
               "name" => "Joe Smith" }
    })
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # restore application-specific ENV variables after each example
  config.after(:each) do
    ENV_VARS.each { |k,v| ENV[k] = v }
  end

  config.before(:each) do |example|
    Rails.cache.clear
  end
end
