# Check for required ENV variables, can be set in .env file

env_vars = %w{ DB_USERNAME DB_HOST HOSTNAME SERVERS SITENAME API_KEY SECRET_KEY_BASE MODE SEARCH SOLR_URL ALM_URL }
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" if ENV[env].blank? }
