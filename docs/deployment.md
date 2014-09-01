# Deployment

## Using Capistrano

Using the deployment automation tool [Capistrano](http://capistranorb.com) is the recommended strategy for code updates via git, database migrations and server restarts. Capistrano assumes that the server has been provisioned using Vagrant or Chef (or via manual installation, see below).

To use Capistrano you need Ruby (at least 1.9.3) installed on your local machine. If you haven't done so, install [Bundler](http://bundler.io/) to manage the dependencies for the ALM application:

```sh
gem install bundler
```

Then go to the ALM Reports git repo that you probably have already cloned in the installation step and install all required dependencies.

```sh
git clone git://github.com/articlemetrics/alm-report.git
cd alm
bundle install
```

#### Edit deployment configuration

For a production deployment setup, edit the deployment configuration for Capistrano by renaming the file `config/deploy/production.rb.example` to `config/deploy/production.rb` and fill in the following information:

* server for roles :app, :web, :db (name or IP address, could all be the same server)
* :deploy_user
* number of background workers, e.g. three workers: :delayed_job_args, "-n 3"
* SSH keys via :ssh_options

A sample `config/deploy/production.rb` could look like this:

```ruby
set :stage, :production
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
set :deploy_user, 'ubuntu'
set :rails_env, :production

role :app, %w{ALM.EXAMPLE.ORG}
role :web, %w{ALM.EXAMPLE.ORG}
role :db,  %w{ALM.EXAMPLE.ORG}

set :ssh_options, {
  user: "ubuntu",
  keys: %w(~/.ssh/id_rsa),
  auth_methods: %w(publickey)
}
```

#### Deploy
We deploy the ALM Reports application with

```sh
bundle exec cap production deploy
```

Replace `production` with `staging` for staging deployment. You can pass in environment variables, e.g. to deploy a different git branch: `cap production deploy BRANCH_NAME=develop`.

The first time this command is run it creates the folder structure required by Capistrano, by default in `/var/www/alm`. To make sure the expected folder structure is created successfully you can run:

```sh
bundle exec cap production deploy:check
```

On subsequent runs the command will pull the latest code from the Github repo, run database migrations, install the dependencies via Bundler, stop and start the background workers, updates the crontab file for ALM, and in production mode precompiles assets (CSS, Javascripts, images).
