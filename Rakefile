require 'rubygems'
require 'cucumber/rake/task'

namespace :ci do

  Cucumber::Rake::Task.new(:charlestest, 'Run a cucumber test, generating HTML report') do |t|
    t.cucumber_opts = "features --tags @networkcallwithcharles --format pretty --format html --out results.html"
  end

end

task :tests => ["ci:charlestest"]

