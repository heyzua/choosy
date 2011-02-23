# Choosy: Picking your arguments carefully

This is a small DSL library for creating command line clients in Ruby.
It is largely inspired by the
[choice|https://github.com/defunkt/choice] and
[commander|https://github.com/visionmedia/commander] libraries, though
it makes some different design decisions than they do.  It is
opinionated software.

This library should:
  - Make creating command line clients relatively easy.
  - Allow you to add validation logic for your arguments
    within the parsing phase, allowing for dependencies between options,
    so that you can more easily validate related options (i.e. if the
    <code>--bold</code> flag requires the <code>--font Arial</code> flag,
    then you should be able to ask for the <code>--font</code> option to
    be validatedfirst, and then the <code>--bold</code> option.
  - Allow you to customize its output using simple ERB templates, 
    so that you can (dynamically) change the output you present to
    your end user without relying upon my formatting.  You should even
    be able to add internationalization printing with relatively little
    effort.

This library should never:
  - Interact with your execution logic.  You can attach executors
    to commands for convenience, but the execution phase
    should be delegated to you, not the parsing library.  Separation
    of concerns, people.
  - Rely on display or user interface libraries like
    Highline, since this is only for parsing command lines.
  - Pollute your namespaces with my DSL function names.  (I really,
    really hate it when libraries do this.) 

# Examples

    #!/usr/bin/env ruby
    # foo.rb

    require 'rubygems'
    require 'choosy'

    FOO_VERSION = 1.0.1

    class FooExecutor
      def execute!(options, args)
        puts "BOLDED!!" if options[:bold]
        options[:count].times do
          puts "#{options[:prefix]}#{options[:words].push('foo').join(',')#{options[:suffix}}"
        end
        puts "and #{args.join ' '}"
        puts "Pushing to #{options[:http]}"
      end
    end

    foo_cmd = Choosy::Command.new :foo do |foo|
      # Add a class to do the execution when you call foo_cmd.execute!
      # You can also use a proc that takes the options and the args, like:
      #    foo.executor { |opts, args| puts 'Hi!' }
      foo.executor FooExecutor.new

      # You can add your custom printer by giving the
      # full path to an ERB template file here.  
      # The default printer is :standard, but you can 
      # also use the builtin printer :compact.  The 
      # output can be colored or uncolored, though the
      # default is colored.
      foo.printer :standard, :colored => true

      foo.summary 'Prints out "foo" to the console"
      foo.desc    <<HERE
    This is a long description about what 'foo' is
    and how it works.  Don't worry your pretty little head
    about the details.
    HERE

      foo.separator 'Required Options:'

      foo.option :prefix do |o|
        o.short '-p'
        o.long  '--prefix', 'PREFIX'
        o.desc  'A prefix for "foo"'
        o.default '<'
        o.required
      end

      # Make sure we validate :suffix after :prefix
      foo.option :suffix => [:prefix] do |o|
        o.short '-s'
        o.long  '--suffix', 'SUFFIX'
        o.desc  'A suffix for "foo"'
        o.required

        o.validate do |suffix|
          if suffix == foo[:prefix]      
            o.fail "You can't matching prefixes and suffixes, you heathen!"
          end
        end
      end

      foo.option :count do |o|
        o.short '-c', 'COUNT'
        # No long option
        o.desc  'The number of times to repeat "foo"'
        o.cast Integer
        o.required
      end

      foo.separator 
      foo.separator 'Options:'

      foo.option :words do |o|
        o.short '-w'
        o.long  '--words', 'WORDS+' # By default, the '+' at the end
                                    # means that this takes multiple
                                    # arguments.  You put a '-' at
                                    # the end of the argument list
                                    # to stop parsing this option
                                    # and allow for regular args.
        o.desc  "Other fun words to put in quotes"
        o.default []
        
        # Sets the exact count of the number of arguments it accepts.
        # also allowable are the single selectors :zero and :one.
        # By default, the option 'WORDS+' sets the range to be
        # {:at_least => 1, :at_most => 1000 }
        o.count {:at_least => 2, :at_most => 10 }

        o.validate do |words|
          words.each do |word|
            if word !~ /\w+/
              o.fail "I can't print that: #{word}"
            end
          end
        end
      end

      # Use the shorthand notation for options
      foo.option :bold => {:long => '--bold', :default => false}

      # Replaces:
      # foo.option :bold do |o|
      #   # No short option
      #   o.long '--bold' # No additional arg name means no argument
      #                   # allowed
      #   o.default false # Defaults to false anyway, but you can be
      #                   # explicit.
      # end

      foo.option :http do |o|
        o.long '--http', 'HTTP?' # The '?' indicates an argument that
                                 # takes 0 or 1 parameters.  You put
                                 # a '-' at the end if enforcing zero
                                 # args to this option.
        o.desc 'Post this fascinating line to the Interwebs!!!'
        o.default "http://www.reddit.com"
      end
      
      options.separator
      # Tail options

      foo.option :debug => {:long => '--debug', 
                            :desc => "Prints out extra debugging output." }

      foo.option :nocolor do |o|
        o.long '--no-color'
        o.desc 'Turns off coloring in the output"
        o.validate do
          foo.printer :standard, :colored => false
        end
      end

      # Adds the standard -h/--help option.
      # Should skip the '-h' flag if already set.
      foo.help  

      # Adds the -v/--version option.
      foo.version "Foo: #{FOO_VERSION}"

      # Now, add some validation for any addtional arguments
      # that are left over after the parsing.
      foo.arguments do |args|
        if args.empty?
          a.fail "You have to pass in empty arguments that do nothing!"
        end
        if args.count >= 3
          a.fail "Whoa there!  You're going argument crazy!"
        end
      end
    end

    if __FILE__ == $0
      # Parses and validates the options.
      foo_cmd.parse! ['--prefix', '{', 
                      '--suffix', '}',
                      '--words', 'high', 'there', 'you', '-', 
                      # The '-' stops parsing this option, so that:
                      'handsom', 'devil',
                      '--http-', # The '-' at the end stops parsing this
                                 # '?' option
                      'http://not.posting.here',
                      '-c, '23', # Count
                      '--', # Stops parsing all arguments
                      '-h', '--help', '-v', '--version' # Ignored
                     ]
      
      require 'pp'
      pp foo_cmd[:prefix]# => '{'
      pp foo_cmd[:suffix]       # => '}'
      pp foo_cmd[:count]        # => 3
      pp foo_cmd[:bold]         # => false
      pp foo_cmd[:words]        # => ['high', 'there', 'you']
      pp foo_cmd[:http]         # => 'http://www.reddit.com'
      pp foo_cmd.args           # => ['handsom', 'devil',
                                #     'http://not.posting.here',
                                #     '-h', '--help', '-v', '--version']
      pp foo_cmd.options        # => {:prefix => '{', :suffix => '}'
                                #     :count => 3, :bold => false,
                                #     :bold => false, 
                                #     :words => ['high', 'there', 'you']
                                #     :http => 'http://www.reddit.com' }
  
      # Now, call the command that does the actual work.
      # This passes the foo_cmd.options and the foo_cmd.args
      # as arguments to the executors 'execute!' method.
      #
      # This allows you to easily associate command classes with
      # commands, without resorting to a hash or combining
      # execution logic with command parsing logic.
      foo_cmd.execute!          # {high,there,you,foo}
                                # {high,there,you,foo}
                                # {high,there,you,foo}
                                # and handsom devil http://not.posting.here -h --help -v --verbose
                                # Pushing to http://www.reddit.com    
  
    end

### Super Commands

You can also combine multiple choices into an uber-choice, creating
commands that look a lot like git or subversion.

First, we create another command.
    
    #!/usr/bin/env ruby
    # bar.rb

    require 'rubygems'
    require 'choosy'

    class BarExecutor
      def execute!(options, args)
        if options[:bold]
          puts "BOLDED BAR"
        else
          puts "bar"
        end
      end
    end
    
    # Create a new command
    bar_cmd = Choosy::Command.new :bar do |bar|
      bar.executor BarExecutor.new
      bar.summary "Just prints 'bar'"
      bar.desc "A truly unremarkable command"

      bar.option :bold do
        long '--bold'
      end

      # Because there is no bar.arguments call,
      # it is now an error if there are extra
      # command line arguments to this command.
    end
    
We can now create our super command.

    #!/usr/bin/env ruby
    # superfoo.rb

    require 'rubygems'
    require 'choosy'
    require 'foo.rb'
    require 'bar.rb'
    
    SUPERFOO_VERSION = "1.0.1"
    
    superfoo = Choosy::SuperCommand.new :superfoo do |superfoo|
      superfoo.summary "This is a superfoo command."
      superfoo.desc "Say something, dammit!"

      # You can also add commands after instantiation.
      # Note that, when added, these commands have their
      # -h/--help/--version flags suppressed, so you'll
      # need to add those flags here.
      superfoo.commands bar_cmd

      # Creates a 'help' command
      superfoo.help do |help|
        help.summary "Prints this help message"
      end

      # Create some global options that are parsed
      # defore subcommand options
    
      superfoo.option :config do |o|
        o.long '--config', 'FILE'
        o.desc "Configure your superfoo with a configuration file."
    
        o.validate do |config|
          if !File.exist? config
            o.fail "Unable to find configuration file!"
          end
        end
      end
    
      # Adds a global --version flag.
      superfoo.version do
        puts "#{SUPERFOO_VERSION}"
      end
    end
    
    # Add a command after the fact.
    superfoo.commands foo_cmd
    
    if __FILE__ == $0
      superfoo.parse! ['-c', '5',
                       'foo',
                       '--config', '~/.superfoo',
                       '--prefix', '{',
                       '--suffix', '}',
                       'cruft',
                       'bar',
                       '--bold']
                       
      require 'pp'
      pp superfoo[:config]                  # => '~/.superfoo'
      pp superfoo.subcommand.name           # => :foo
      pp superfoo.subcommand[:prefix]       # => '{'
      pp superfoo.subcommand[:suffix]       # => '}'
      pp superfoo.subcommand[:count]        # => 2
      pp superfoo.subcommand[:bold]         # => true
      pp superfoo.subcommand.options        # => {:prefix => '{', :suffix => '}'
                                            #     :count => 2,
                                            #     :bold => true, 
                                            #     :words => [],
                                            #     :http => 'http://www.reddit.com',
                                            #     :config => '~/.superfoo' }
      pp superfoo.subcommand.args           # => ['cruft', 'bar']
      
      pp superfoo.options                   # => {:prefix => '{', :suffix => '}'
                                            #     :count => 2,
                                            #     :bold => true, 
                                            #     :words => [],
                                            #     :http => 'http://www.reddit.com'
                                            #     :config => '~/.superfoo' }
      pp superfoo.args                      # => ['cruft', 'bar']
  
      # Now, we can call the subcommand
      superfoo.execute!                     ## Calls superfoo.subcommand.execute!
                                            ## Prints:
                                            # BOLDED!!
                                            # {foo}
                                            # {foo}
                                            # and cruft bar
                                            # pushing to http://www.reddit.com
  
      # We got what we wanted, so reset the parser.
      superfoo.reset!
  
      # Instead of parsing the 'bar' parameter as an argument to
      # the foo command, so that when the first argument that matches
      # another command name is encountered, it stops parsing the
      # current command and passes the rest of the arguments to the
      # next command.
      #
      # You can also set this inside a SuperChoosy.new {|s| ... } 
      # block.
      superfoo.parsimonious
  
      superfoo.parse! ['-c', '5',
                       'foo',
                       '--config', '~/.superfoo',
                       '--prefix', '{',
                       '--suffix', '}',
                       'cruft',
                       'bar',
                       '--bold']
                       
      pp superfoo[:config]                      # => '~/.superfoo'
      pp superfoo.subcommand.name               # => :foo
      pp superfoo.subcommands[0].name           # => :foo
      pp superfoo.subcommands[0][:prefix]       # => '{'
      pp superfoo.subcommands[0][:suffix]       # => '}'
      pp superfoo.subcommands[0][:count]        # => 2
      pp superfoo.subcommands[0][:bold]         # => true
      pp superfoo.subcommands[0].options        # => {:prefix => '{', :suffix => '}'
                                                #     :count => 2,
                                                #     :bold => false, 
                                                #     :words => [],
                                                #     :http => 'http://www.reddit.com'
                                                #     :config => '~/.superfoo' }
      pp superfoo.subcommands[0].args           # => ['cruft']
  
      pp superfoo.subcommands[1].name           # => :bar
      pp superfoo.subcommands[1][:bold]         # => true
      pp superfoo.subcommands[1].options        # => {:bold => true,
                                                #     :config => '~/.superfoo'}
      pp superfoo.subcommands[1].args           # => []
      
      pp superfoo.options                       # => {:config => '~/.superfoo'}
      pp superfoo.args                          # => []
  
      # Now, execute the subcommands in order
      superfoo.execute!        ## Same as:
                               #  superfoo.subcommands.each do |subcommand|
                               #    command.execute!
                               #  end
                               ## Prints:
                               # {foo}
                               # {foo}
                               # and cruft
                               # pushing to http://www.reddit.com
                               # BOLDED BAR
    end

### TODO: Output Printing
