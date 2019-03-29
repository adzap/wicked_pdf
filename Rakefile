require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rails/version'
require 'bundler/gem_tasks'

desc 'Default: run unit tests.'
task :default => [:test, :rubocop]

desc 'Test the wicked_pdf plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run RuboCop'
task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

desc 'Generate documentation for the wicked_pdf gem.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WickedPdf'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
