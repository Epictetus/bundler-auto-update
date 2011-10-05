require 'bundler/gem_tasks'

desc "Run specs"
task :spec do
  raise unless system 'bundle exec rspec spec'
end

desc "Run cucumber"
task :cucumber do
  raise unless system 'bundle exec cucumber features'
end

task :default => [:spec, :cucumber]
