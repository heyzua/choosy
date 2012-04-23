$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'rake'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'choosy/rake'

desc "Default task"
task :default => [:spec]

desc "Run all of the specifications."
task :spec => ['spec:default']
namespace :spec do
  task :default => [:rspec, :cucumber]

  desc "Run the RSpec tests."
  RSpec::Core::RakeTask.new :rspec

  desc "Runs all of the cucumber tasks. Add 'tag=TAG' to run only matching tags."
  Cucumber::Rake::Task.new :cucumber do |cucumber|
    cucumber.cucumber_opts = ["-t #{ENV['tag'] || "all"}", "features"]
  end
end

desc "Rebuilds the README.md file."
task :readme do
  File.open 'docs/README.md', 'r'  do |template|
    File.open 'README.md', 'w' do |output|
      template.each do |line|
        if line =~ /^INCLUDE\((.*?),\s*(.*?)\)/
          output.puts "    ```#{$2}"

          File.open $1, 'r' do |toinsert|
            exclude = false
            toinsert.each_line do |ins|
              if ins =~ /^#=begin/
                exclude = true
              end
              output.puts "    #{ins}" unless exclude
              if ins =~ /^#=end/
                exclude = false
              end
            end
          end

          output.puts "    ```"
        else
          output.puts line
        end
      end
    end
  end
end

desc "Cleans the generated files."
task :clean => ['gem:clean']

desc "Runs the full deploy"
task :push => [:readme, 'choosy:release', :clean]
