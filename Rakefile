require 'rake/testtask'
require 'rubygems/package_task'

task :default => :test

Rake::TestTask.new do |t|
  t.warning = true
end

eval("$specification = begin; #{IO.read('sprockets-redirect.gemspec')}; end")
Gem::PackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end
