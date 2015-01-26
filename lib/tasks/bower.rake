namespace :bower do
  desc "Install bower packages"
  task :install => :environment do
    sh "node_modules/bower/bin/bower install"
  end
end
