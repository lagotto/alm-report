## Manual installation
These instructions assume a fresh installation of Ubuntu 14.04 and a user with sudo privileges. Installation on other Unix/Linux platforms should be similar, but may require additional steps to install Ruby 1.9.

#### Update package lists

```sh
sudo apt-get update
```

#### Install required packages
`libxml2-dev` and `libxslt1-dev` are required for XML processing by the `nokogiri` gem, `nodejs` provides Javascript for the `therubyracer` gem. `readline` is a library for reading from standard inputs (like the Rails console). Other libraries cover dependencies of various Ruby gems.

```sh
sudo apt-get install curl patch openssl ca-certificates libreadline6 \
        libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev \
        libsqlite3-dev autoconf \
        libgdbm-dev libncurses5-dev libffi-dev \
        build-essential git-core libxml2-dev libxslt1-dev nodejs
```

#### Install Ruby 2.1.2
We only need one Ruby version, but we'll want to use all of the performance benefits of Ruby 2.1.2, so let's just compile from source:

```sh
wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
tar -xzvf ruby-2.1.2.tar.gz
cd ruby-2.1.2/
./configure
make
sudo make install
ruby -v
```

#### Install databases

```sh
sudo apt-get install mysql-server
```

#### Install Memcached
Memcached is used to cache requests (in particular API requests), and the default configuration can be used. If you want to run memcached on a different host, change `config.cache_store = :dalli_store, { :namespace => "alm-report" }` in `config/environments/production.rb` to `config.cache_store = :dalli_store, 'cache.example.com', { :namespace => "alm-report" }`.

```sh
sudo apt-get install memcached
```

#### Install Nginx and Passenger

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates
```

Open repository config file:

```
sudo nano /etc/apt/sources.list.d/passenger.list

Add following repository source:

```
deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main
```

And then install:

```
sudo apt-get install nginx-full passenger
```

#### Set up Nginx

Your `/etc/nginx/nginx.conf` file should look something like this:

```
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections 768;
  # multi_accept on;
}

http {

  ##
  # Basic Settings
  ##

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;
  # server_tokens off;

  # server_names_hash_bucket_size 64;
  # server_name_in_redirect off;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  ##
  # Logging Settings
  ##

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  ##
  # Gzip Settings
  ##

  gzip on;
  gzip_disable "msie6";

  # gzip_vary on;
  # gzip_proxied any;
  # gzip_comp_level 6;
  # gzip_buffers 16 8k;
  # gzip_http_version 1.1;
  # gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

  ##
  # nginx-naxsi config
  ##
  # Uncomment it if you installed nginx-naxsi
  ##

  # include /etc/nginx/naxsi_core.rules;

  ##
  # Phusion Passenger config
  ##
  # Uncomment it if you installed passenger or passenger-enterprise
  ##

  passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
  passenger_ruby /usr/bin/ruby;

  ##
  # Virtual Host Configs
  ##

  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
```

#### Install ALM Reports code
You may have to set the permissions first, depending on your server setup. Passenger by default is run by the user who owns `config.ru`.

```sh
git clone git://github.com/articlemetrics/alm-report.git /var/www/alm-report
```

#### Install Bundler and Ruby gems required by the application
Bundler is a tool to manage dependencies of Ruby applications: http://gembundler.com. We have to install `therubyracer` gem as sudo because of a permission problem (make sure the version matches the version in `Gemfile` in the ALM root directory).

```sh
sudo gem install bundler
sudo gem install therubyracer -v '0.12.1'

cd /var/www/alm-report
bundle install
```

#### Set ALM Reports configuration settings
You want to set the MySQL username/password in `database.yml`, using either the root password that you generated when you installed MySQL, or a different MySQL user.

```sh
cd /var/www/alm-report
cp config/database.yml.example config/database.yml
cp config/settings.yml.example config/settings.yml
```

#### Start Nginx

`/etc/init.d/nginx start`

You can now access the ALM Reports application with your web browser at the name or IP address (if it is the only virtual host) of your Ubuntu installation.
