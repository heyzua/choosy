#!/usr/bin/env ruby -w
# superfoo.rb

$LOAD_PATH.unshift File.join(File.dirname(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift File.join(File.dirname(File.dirname(__FILE__)), 'examples')
require 'choosy'
require "foo"
require "bar"

SUPERFOO_VERSION = "1.0.1"

superfoo = Choosy::SuperCommand.new :superfoo do
  summary "This is a superfoo command"
  para "Say something, dammit!"

  # You can also add commands after instantiation.
  # Note that, when added, these commands have their
  # -h/--help/--version flags suppressed, so you'll
  # need to add those flags here.
  command bar_cmd
  command foo_cmd

  # Creates a 'help' command, message optional
  help "Prints this help message"

  # Create some global options that are parsed
  # defore result options

  # Here, check that a YAML file exists, and attempt
  # to load it's parsed contents into this option.
  # There is also a 'file' type that checks to see
  # if the file exists. With both 'file' and 'yaml',
  # if the file is missing, the option fails with an
  # error.
  yaml :Config, "Configure your superfoo with a YAML configuration file." do
    default File.join(ENV['HOME'], '.superfoo.yml')
  end

  # Adds a global --version flag.
  version "#{SUPERFOO_VERSION}"
end

if __FILE__ == $0
  args = ['foo',
          '-c', '5',
          '--config', '~/.superfoo',
          '--prefix', '{',
          '--suffix', '}',
          'cruft',
          'bar',
          '--bold']

  result = superfoo.parse!(args)

  require 'pp'
  pp result[:config]        # => '~/.superfoo'
  pp result.name            # => :foo
  pp result[:prefix]        # => '{'
  pp result[:suffix]        # => '}'
  pp result[:count]         # => 2
  pp result[:bold]          # => true
  pp result.options         # => {:prefix => '{', :suffix => '}'
                            #     :count => 2,
                            #     :bold => true, 
                            #     :words => [],
                            #     :config => '~/.superfoo' }
  pp result.args            # => ['cruft', 'bar']
  
  # Now, we can call the result
  superfoo.execute!(args)   ## Calls superfoo.result.execute!
                            ## Prints:
                            # BOLDED!!
                            # {foo}
                            # {foo}
                            # and cruft bar
  
  # Instead of parsing the 'bar' parameter as an argument to
  # the foo command, so that when the first argument that matches
  # another command name is encountered, it stops parsing the
  # current command and passes the rest of the arguments to the
  # next command.
  #
  # In this case, we call the 'alter' method to use the DSL
  # syntax again to alter this command.
  #
  # You can also set this inside a SuperChoosy.new {...}
  # block.
  superfoo.alter do
    parsimonious
  end
  
  result = superfoo.parse!(args)
                   
  pp result.name                    # => :superfoo
  pp result[:config]                # => '~/.superfoo'
  pp result.subresults[0].name      # => :foo
  pp result.subresults[0][:prefix]  # => '{'
  pp result.subresults[0][:suffix]  # => '}'
  pp result.subresults[0][:count]   # => 2
  pp result.subresults[0][:bold]    # => true
  pp result.subresults[0].options   # => {:prefix => '{', :suffix => '}'
                                    #     :count => 2,
                                    #     :bold => false, 
                                    #     :words => [],
                                    #     :config => '~/.superfoo' }
  pp result.subresults[0].args      # => ['cruft']
  
  pp result.subresults[1].name      # => :bar
  pp result.subresults[1][:bold]    # => true
  pp result.subresults[1].options   # => {:bold => true,
                                    #     :config => '~/.superfoo'}
  pp result.subresults[1].args      # => []
  
  # Now, execute the results in order
  superfoo.execute!(args)       ## Same as:
                                #  results.each do |subcommand|
                                #    command.execute!
                                #  end
                                ## Prints:
                                # {foo}
                                # {foo}
                                # and cruft
                                # BOLDED BAR
end

