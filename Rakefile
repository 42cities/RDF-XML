require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test library.'
Spec::Rake::SpecTask.new(:test) do |test|
  test.spec_files = Dir.glob('test/**/*_spec.rb')
  test.spec_opts << '--format specdoc'
end

desc 'Generate documentation.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'RDF-XML'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :install => [:build_gem, :local_install]

desc 'Make a gem package'
task :build_gem do
  system 'rm rdf-xml-*.gem'
  system 'gem build .gemspec'
end

desc 'Install gem locally'
task :local_install do
  system 'sudo gem install --local rdf-xml-*.gem'
end

