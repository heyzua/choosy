require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'choosy/rake'

desc "Default task"
task :default => [:spec]

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
task :clean => ['gem:clean']

desc "Runs the full deploy"
task :push => [:release, :clean]
