---
layout: page
title: "Development"
---

ALM Reports is a typical Ruby on Rails web application. The application has been tested with Nginx/Passenger. ALM Reports uses Ruby on Rails 3.2.x, migration to Rails 4.x is planned for 2014.

#### Ruby
ALM Reports requires Ruby 1.9.3 or greater, and has been tested with Ruby 1.9.3, 2.0 and 2.1. Not all Linux distributions include Ruby 1.9 as a standard install, which makes it more difficult than it should be. [RVM] and [Rbenv] are Ruby version management tools for installing Ruby 1.9. Unfortunately they also introduce additional dependencies, making them sometimes not the best choices in a production environment. The Chef script below installs Ruby 2.1.

[RVM]: http://rvm.io/
[Rbenv]: https://github.com/sstephenson/rbenv

#### Installation Options

* automated installation with Vagrant (recommended)
* manual installation

## Automated Installation
This is the recommended way to install the ALM Reports application. The required applications and libraries will automatically be installed in a self-contained virtual machine, using [Vagrant] and [Chef Solo].

Start by downloading and installing [Vagrant], all of the relevant plugins will be installed automatically when you first run `vagrant up`.

The following providers have been tested with the ALM application:

* VirtualBox
* VMware Fusion or Workstation
* Amazon AWS
* Digital Ocean

VirtualBox and VMware are for local installations, e.g. on a developer machine, whereas the other options are for cloud installations. With the exception of VirtualBox and Amazon AWS you need to install the appropriate [Vagrant plugin](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins) with these providers, e.g. for Digital Ocean:

```sh
vagrant plugin install vagrant-digitalocean
```

The VMware plugin requires a commercial license, all other plugins are freely available as Open Source software.

### Custom settings (passwords, API keys)

This is an optional step. Rename the file `config.json.example` to `config.json` and add your custom settings to it, including API keys and the MySQL password. This will automatically configure the application with your settings.

Some custom settings for the virtual machine are stored in the `Vagrantfile`, and that includes your cloud provider access keys, the ID base virtual machine with Ubuntu 14.04 from by your cloud provider, RAM for the virtual machine, and networking settings for a local installation. A sample configuration for AWS would look like:

```ruby
config.vm.hostname = "SUBDOMAIN.EXAMPLE.ORG"

config.vm.provider :aws do |aws, override|
  aws.access_key_id = "EXAMPLE"
  aws.secret_access_key = "EXAMPLE"
  aws.keypair_name = "EXAMPLE"
  aws.security_groups = ["EXAMPLE"]
  aws.instance_type = 'm1.small'
  aws.ami = "ami-0307d674"
  aws.tags = { Name: 'Vagrant alm' }

  override.ssh.username = "ubuntu"
  override.ssh.private_key_path = "/EXAMPLE.pem"
end
```
For Digital Ocean the configuration could look like this:

```ruby
config.vm.hostname = "SUBDOMAIN.EXAMPLE.ORG"

config.vm.provider :digital_ocean do |provider, override|
  override.ssh.private_key_path = '~/.ssh/id_rsa'
  override.vm.box = 'digital_ocean'
  override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  override.ssh.username = "ubuntu"

  provider.region = 'nyc2'
  provider.image = 'Ubuntu 12.04.4 x64'
  provider.size = '1GB'

  # please configure
  override.vm.hostname = "ALM.EXAMPLE.ORG"
  provider.token = 'EXAMPLE'
end
```

The sample configurations for AWS and Digital Ocean is included in the `Vagrantfile`.

Then install all the required software for the ALM application with:

```sh
git clone git://github.com/articlemetrics/alm-report.git
cd alm
vagrant up
```

[VirtualBox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: http://downloads.vagrantup.com/
[Omnibus]: https://github.com/schisamo/vagrant-omnibus
[Chef Solo]: http://docs.opscode.com/chef_solo.html

This can take up to 15 min, future updates with `vagrant provision` are of course much faster. To get into in the virtual machine, use user `vagrant` with password `vagrant` or do:

```sh
vagrant ssh
cd /var/www/alm-report
```

This uses the private SSH key provided by you in the `Vagrantfile` (the default insecure key for local installations using VirtualBox is `~/.vagrant.d/insecure_private_key`). The `vagrant` user has sudo privileges. The MySQL password is stored at `config/database.yml`, and is auto-generated during the installation. The database servers can be reached from the virtual machine or via port forwarding (configured in `Vagrantfile`). Vagrant syncs the folder on the host containing the checked out ALM git repo with the folder `/var/www/alm-report/current` on the guest.

## Configuring ALM and search backends

It’s possible to use different ALM (any ALM v3 API) and search backends (CrossRef or PLOS) since release 2.1. For example, if you would like to use CrossRef's API for searching, and CrossRef’s ALM API for metrics, you would configure your `config/settings.yml` file like so:

```
...
search: crossref
alm:
  url: http://det.labs.crossref.org
  api_key: # your ALM API key
...
```

For an example, check out [settings.yml.example](https://github.com/articlemetrics/alm-report/blob/master/config/settings.yml.example).

## Accessing the application

By default, the configured IP during development of the Rails application is [10.2.2.2](http://10.2.2.2). When you want to access it, go to [http://10.2.2.2](http://10.2.2.2) in your browser.
