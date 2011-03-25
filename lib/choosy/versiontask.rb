
# This is a library task that others can use to expose functionality in their rake files
# It defines the '$version' global variable to let users pull this information out
# into their own scripts.

require 'choosy/version'

desc "Shows the current version number."
task :version => ['version:load'] do
  puts "Current version: #{$version.to_s}"
end

namespace :version do
  task :load do
    puts Dir.pwd
    if ENV['VERSION_FILE']
      $version = Choosy::Version.new(ENV['VERSION_FILE'])
    else
      $version = Choosy::Version.load(:dir => Dir.pwd, :relpath => 'lib')
    end
  end

  [:tiny, :minor, :major].each do |type|
    desc "Bumps the #{type} revision number."
    task type => :load do
      $version.version!(type)
      puts "New version: #{$version.to_s}"
    end
  end
end
