
# This is a library task that others can use to expose functionality in their rake files
# It defines the '$version' global variable to let users pull this information out
# into their own scripts.

module SH
  def self.attempt(command, options={}, &block)
    contents = nil
    IO.popen("#{command} 2>&1", 'r') do |io|
      contents = io.read
    end
    if $? != 0
      yield [$?, contents] if block_given?

      if options[:error]
        raise options[:error]
      else
        puts contents
        raise "Unable to execute command: #{command}" unless options[:fail] == false
      end
    end 

    if options[:success] && contents !~ options[:success]
      raise "Command failed: #{command}"
    elsif options[:failure] && contents =~ options[:failure]
      raise "Command didn't succeed: #{command}"
    end

    puts contents unless options[:quiet]
  end

  def self.files(ending_with, &block)
    files = Dir.glob("*#{ending_with}")

    raise "No #{ending_with} files found." if files.empty?
    
    files.each do |file|
      yield file
    end
  end
end

#########################################################################
# Version
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

#########################################################################
# Release
namespace :release do
  
end

#########################################################################
# Git
namespace :git do
  task :diff => ['version:load'] do
    SH.attempt "git diff --exit-code", :error => "git diff: Your work doesn't seem to be checked in!", :quiet => true
  end

  task :tag => [:diff, 'version:load'] do
    sh "Tagging version #{$version}"
    SH.attempt "git tag -a -m 'Tagging release #{$version}' v#{$version}" do |code, contents|
      SH.attempt "git tag -d v#{$version}", :error => "git tag: unable to delete tag"
      raise "Unable to commit tag."
    end
  end

  task :push => [:diff, 'version:load'] do
    SH.attempt "git push"
    SH.attempt "git push --tags"
  end
end

#########################################################################
# Gems
desc "Build the current gemspecs."
task :gem => ['gem:build']

namespace :gem do
  desc "Builds the current gemspec."
  task :build do
    SH.files('gemspec') do |gemspec|
      puts "  Building gemspec: #{gemspec}"
      SH.attempt "gem build #{gemspec}"
    end
  end
  
  desc "Pushes the current gem."
  task :push => :build do
    SH.files ("#{$version}.gem") do |gem|
      puts "  Pushing gems: #{gem}"
      SH.attempt "gem push #{gem}"
    end
  end

  desc "Installs the current gem."
  task :install => :build do
    SH.files ("#{$version}.gem") do |gem|
      puts "  Installing gem: #{gem}"
      SH.attempt "gem install --no-ri --no-rdoc #{gem}"
    end
  end

  task :clean do
    rm Dir.glob('*.gem')
  end
end
