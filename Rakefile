require 'bundler/setup'
require 'rake/testtask'
require 'rubygems/package_task'
require 'appraisal'

task :default => :test

task :test_all => 'appraisal:install' do
  ENV['WITHIN_APPRAISAL'] = '1'
  exec 'rake appraisal test'
end

Rake::TestTask.new(:test) do |t|
  t.test_files = Dir.glob("test/**/*_test.rb")
  t.verbose = true
  t.warning = true
end

eval("$specification = begin; #{IO.read('sprockets-redirect.gemspec')}; end")
Gem::PackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end
