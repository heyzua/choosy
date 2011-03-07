#!/usr/bin/env ruby -w
# bar.rb

$LOAD_PATH.unshift File.join(File.dirname(File.dirname(__FILE__)), 'lib')
require 'choosy'

# Create a new command
bar_cmd = Choosy::Command.new :bar do
  executor do |args, options|
    if options[:bold]
      puts "BOLD!!!"
    else
      puts "plain"
    end
  end

  summary "Displays when this is a subcommand"
  para "Just prints 'bar'"
  para "A truly unremarkable command"

  header 'Option:'
  boolean :bold, "Bolds something" do
    negate 'un'
  end

  # Because there is no bar.arguments call,
  # it is now an error if there are extra
  # command line arguments to this command.
end

if __FILE__ == $0
  args = ['--un-bold']
  
  result = bar_cmd.parse!(args)
  
  require 'pp'
  pp result.options[:bold]           # => false
  pp result.args                     # => []
  
  bar_cmd.execute!(args)             # => 'plain'

  args << 'should-throw-error'
  bar_cmd.execute!(args)
end
