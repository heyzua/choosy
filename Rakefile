# $LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
# $LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'rubygems'
require 'rake'
#require 'rake/rdoctask'
require 'rspec/core/rake_task'
require './lib/choosy/version'

PACKAGE_NAME = "choosy"
PACKAGE_VERSION = Choosy::Version

desc "Default task"
task :default => [ :spec ]

desc "Build documentation"
task :doc => [ :rdoc ]

#task :rdoc => SOURCE_FILES

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['-b', '-c', '-f', 'p']
  t.fail_on_error = false
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name           = PACKAGE_NAME
    gem.version        = PACKAGE_VERSION
    gem.summary        = 'Yet another option parsing library.'
    gem.description    = 'This is a DSL for creating more complicated command line tools.'
    gem.email          = ['madeonamac@gmail.com']
    gem.authors        = ['Gabe McArthur']
    gem.homepage       = 'http://github.com/gabemc/choosy'
    gem.files          = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    
    gem.add_development_dependency 'rspec', '~> 2.5'
  end
rescue LoadError
  puts "Jeweler or dependencies are not available.  Install it with: gem install jeweler"
end

desc "Cleans the generated files."
task :clean do
  rm Dir.glob('*.gemspec')
  rm Dir.glob('*.gem')
  rm_rf 'pkg'
end

desc "Deploys the gem to rubygems.org"
task :gem => :release do
  system("gem build #{PACKAGE_NAME}.gemspec")
  system("gem push #{PACKAGE_NAME}-#{PACKAGE_VERSION}.gem")
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end
