begin
  require 'choosy/versiontask'
rescue LoadError => e
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
  require 'choosy/versiontask'
end

require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'bundler'
Bundler::GemHelper.install_tasks

PACKAGE_NAME = "choosy"

desc "Default task"
task :default => [ :spec ]

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new :spec

desc "Build documentation"
task :doc => [ :rdoc ] do
  File.open 'docs/README.markdown', 'r'  do |template|
    File.open 'README.markdown', 'w' do |output|
      template.each do |line|
        if line =~ /^>>> (.*)/
          puts $1
          File.open $1, 'r' do |toinsert|
            exclude = false
            toinsert.each_line do |ins|
              if ins =~ /^##-/
                exclude = true
              end
              output.puts "    #{ins}" unless exclude
              if ins =~ /^##\+/
                exclude = false
              end
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

desc "Cleans the generated files."
task :clean do
  rm Dir.glob('*.gemspec')
  rm Dir.glob('*.gem')
  rm_rf 'pkg'
end

desc "Deploys the gem to rubygems.org"
task :gem => [:doc, :release] do
  sh "gem build #{PACKAGE_NAME}.gemspec"
  sh "gem push #{PACKAGE_NAME}-#{$version.to_s}.gem"
  sh "git tag -m 'Tagging release #{$version.to_s}' v#{$version.to_s}"
  sh "git push origin :refs/tags/#{$version.to_s}"
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end
