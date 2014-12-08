# Check for required ENV variables, can be set in .env file

env_vars = %w{ DB_USERNAME DB_HOST HOSTNAME SERVERS SITENAME SECRET_KEY_BASE MODE SEARCH SOLR_URL SOLR_MAX_DOIS ALM_URL ALM_API_KEY}
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" if ENV[env].blank? }
