#!/usr/bin/env ruby
##-
BEGIN {$VERBOSE = true}
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)
##+

# superfoo.rb
require 'choosy'
require 'foo'
require 'bar'

SUPERFOO_VERSION = "1.0.1"

superfoo = Choosy::SuperCommand.new :superfoo do
  summary "This is a superfoo command"
  para "Say something, dammit!"

  # You can also add commands after instantiation.
  # Note that, when added, these commands have their
  # -h/--help/--version flags suppressed, so you'll
  # need to add those flags here.
  command $bar_cmd
  command $foo_cmd

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
          '--config', 'superfoo.yaml',
          '--prefix', '{',
          '--suffix', '}',
          'cruft',
          'bar',
          '--bold']

  result = superfoo.parse!(args)

  require 'pp'
  pp result[:Config]        # => {:here => 'text'} # Pulled the config!

  foores = result.subresults[0]
  
  pp foores[:Config]        # => {:here => 'text'} # Passed along!
  pp foores[:prefix]        # => '{'
  pp foores[:suffix]        # => '}'
  pp foores[:count]         # => 5
  pp foores[:bold]          # => true
  pp foores.options         # => {:prefix => '{', :suffix => '}'
                            #     :count => 5,
                            #     :bold => true, 
                            #     :words => [],
                            #     :config => '~/.superfoo' }
  pp foores.args            # => ['cruft', 'bar']
  
  # Now, we can call the result
  superfoo.execute!(args)   ## Calls superfoo.result.execute!
                            ## Prints:
                            # BOLDED!!
                            # {foo}
                            # {foo,foo}
                            # {foo,foo,foo}
                            # {foo,foo,foo,foo}
                            # {foo,foo,foo,foo,foo}
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

  foores = result.subresults[0]
  pp foores[:Config]                # => {:here => 'text'} # Passed along!
  pp foores.command.name            # => :foo
  pp foores[:prefix]                # => '{'
  pp foores[:suffix]                # => '}'
  pp foores[:count]                 # => 5
  pp foores[:bold]                  # => true
  pp foores.options                 # => {:prefix => '{', :suffix => '}'
                                    #     :count => 5,
                                    #     :bold => false, 
                                    #     :words => [],
                                    #     :config => {:here => 'text'}
                                    #    }
  pp foores.args                    # => ['cruft']
  
  barres = result.subresults[1]
  pp barres.command.name            # => :bar
  pp barres[:bold]                  # => true
  pp barres.options                 # => {:bold => true,
                                    #     :config => {:here => 'text'}
                                    #    }
  pp barres.args                    # => []
  
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

