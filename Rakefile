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
task :doc => [ :rdoc ] do
  File.open 'docs/README.markdown', 'r'  do |template|
    File.open 'README.markdown', 'w' do |output|
      template.each do |line|
        if line =~ /^>>> (.*)/
          puts $1
          File.open $1, 'r' do |inserted|
            inserted.each do |ins|
              output.puts "    #{ins}"
            end
          end
        else
          output.puts line
        end
      end
    end
  end
end

desc "Create RDocs: TODO"
task :rdoc

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new :spec

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
task :gem => [:doc, :release] do
  system("gem build #{PACKAGE_NAME}.gemspec")
  system("gem push #{PACKAGE_NAME}-#{PACKAGE_VERSION}.gem")
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end
