require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :db do
  task :create do
    `touch spec/testdb.sqlite`
  end
  
  task :drop do
    `rm spec/testdb.sqlite`
  end
end