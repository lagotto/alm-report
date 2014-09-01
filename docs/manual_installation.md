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

#### Install Apache and dependencies required for Passenger

```sh
sudo apt-get install apache2 apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev
```

#### Install and configure Passenger
Passenger is a Rails application server: http://www.modrails.com. Update `passenger.load` and `passenger.conf` when you install a new version of the passenger gem.

```sh
sudo gem install passenger -v 4.0.50
sudo passenger-install-apache2-module --auto

# /etc/apache2/mods-available/passenger.load
LoadModule passenger_module /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.50/ext/apache2/mod_passenger.so

# /etc/apache2/mods-available/passenger.conf
PassengerRoot /usr/local/lib/ruby/gems/2.1.0/gems/passenger-4.0.50
PassengerRuby /usr/local/bin/ruby

sudo a2enmod passenger
```

#### Set up virtual host
Please set `ServerName` if you have set up more than one virtual host. Also don't forget to add`AllowEncodedSlashes On` to the Apache virtual host file in order to keep Apache from messing up encoded embedded slashes in DOIs. Use `RailsEnv development` to use the Rails development environment.

```apache
# /etc/apache2/sites-available/alm-report
<VirtualHost *:80>
  ServerName localhost
  RailsEnv production
  DocumentRoot /var/www/alm-report/public

  <Directory /var/www/alm-report/public>
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
  </Directory>

  # Important for ALM: keeps Apache from messing up encoded embedded slashes in DOIs
  AllowEncodedSlashes On

</VirtualHost>
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

#### Start Apache
We are making `alm-report` the default site.

```sh
sudo a2dissite default
sudo a2ensite alm-report
sudo service apache2 reload
```

You can now access the ALM Reports application with your web browser at the name or IP address (if it is the only virtual host) of your Ubuntu installation.
