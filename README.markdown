# Choosy: Picking your arguments carefully

This is a small DSL library for creating command line clients in Ruby. It is largely inspired by the <a href="https://github.com/defunkt/choice">choice</a>, <a href="https://github.com/visionmedia/commander">commander</a>, and <a href="http://furius.ca/optcomplete/">optcomplete.py</a> libraries, though it makes some different design decisions than they do.  It is opinionated software.

This library should:

  - Make creating command line clients relatively easy.
  - Make creating supercommands like git, subversion, and gem easier.
  - Allow you to add validation logic for your arguments within the parsing phase.
  - Allowing for dependencies between options, so that you can more easily validate related options (i.e. if the<code>--bold</code> flag requires the <code>--font Arial</code> flag, then you should be able to ask for the <code>--font</code> option to be validated first, and then the <code>--bold</code> option.
  - Allow you to customize its output using your own formatting system.
  - Allow you to customize the output to your specifications.

This library should never:

  - Interact with your execution logic.  You can attach executors to commands for convenience, but the execution phase should be delegated to you, not the parsing library.  Separation of concerns, people.
  - Rely on display or user interface libraries like Highline, since this is only for parsing command lines.
  - Pollute your namespaces with my DSL function names.  (I really, really hate it when libraries do this.) 

# Examples

    #!/usr/bin/env ruby -w
    # foo.rb
    
    $LOAD_PATH.unshift File.join(File.dirname(File.dirname(__FILE__)), 'lib')
    require 'choosy'
    
    FOO_VERSION = '1.0.1'
    
    class FooExecutor
      def execute!(args, options)
        puts "BOLDED!!" if options[:bold]
        options[:count].times do
          puts "#{options[:prefix]}#{options[:words].push('foo').join(',')}#{options[:suffix]}"
        end
        puts "and #{args.join ' '}"
      end
    end
    
    foo_cmd = Choosy::Command.new :foo do |foo|
      # Add a class to do the execution when you call foo_cmd.execute!
      # You can also use a proc that takes the options and the args, like:
      #    executor { |args, options| puts 'Hi!' }
      executor FooExecutor.new
    
      # When used as a subcommand, you need a summary for the help screen
      summary "This is a nice command named 'foo'"
    
      # You can add your custom printer by giving the
      # full path to an ERB template file here.  
      # The default printer is :standard, but you can 
      # also use the builtin printer :erb, with the :tempates
      # parameter to set the erb template you wish to use. The 
      # output can be colored or uncolored, though the
      # default is colored.
      printer :standard, :color => true, :header_styles => [:bold, :green]
    
      para 'Prints out "foo" to the console'
      para 'This is a long description of what foo is an how it works. This line will assuredly wrap the console at least once, since it it such a long line, but it will be wrapped automatically by the printer, above. If you want to, you can add write "printer :standard, :max_width => 80" to set the maximum column width that the printer will allow (not respected by ERB templates).'
      
      header 'Required Options:' # Formatted according to the header_styles for the printer
    
      # A shorthand for a common option type.
      # It adds the '-p/--prefix PREFIX' infomation for you.
      single :prefix, "A prefix for 'foo'" do
        default '<'
        required
      end
    
      # The long way to do the same thing as above, except with
      # explicitly named dependencies
      option :suffix => [:prefix] do
        short '-s'
        long  '--suffix', 'SUFFIX'
        desc  'A suffix for "foo"'
        required
    
        validate do |suffix, options|
          if suffix == options[:prefix]      
            die "You can't matching prefixes and suffixes, you heathen!"
          end
        end
      end
    
      # Just like the 'single' method above, except now it automatically
      # requires/casts the argument to this flag into an integer.  These commands
      # also take an optional hash as the last argument, which can be used instead
      # of a block.
      integer :count, 'The number of times to repeat "foo"', :required => true
    
      header 'Options:', :bold, :blue # Format this header differently, overrides 'header_styles'
    
      option :words do
        short '-w'
        long  '--words', 'WORDS+' # By default, the '+' at the end
                                    # means that this takes multiple
                                    # arguments.  You put a '-' at
                                    # the end of the argument list
                                    # to stop parsing this option
                                    # and allow for regular args.
        desc  "Other fun words to put in quotes"
        
        # Sets the exact count of the number of arguments it accepts.
        # also allowable are the single selectors :zero and :one.
        # By default, the option 'WORDS+' sets the range to be
        # {:at_least => 1, :at_most => 1000 }
        count :at_least => 2, :at_most => 10
    
        validate do |words, options|
          words.each do |word|
            if word !~ /\w+/
              die "I can't print that: #{word}"
            end
          end
        end
      end
    
      # Alternatively, we could have done the following:
      strings :words, "Other fun words to put in quotes" do
        count 2..10
        default []
        validate do |words, options|
          words.each do |word|
            if word !~ /\w+/
              die "I can't print that: #{word}"
            end
          end
        end
      end
    
      # Yet another shorthand notation for options, since they
      # are boolean by default. Here, we add a negation to the
      # long flag of the option, creating [-b|--bold|--un-bold] flags.
      # By default, calling 'negate' in a block without an argument
      # uses the '--no-' prefix instead.
      boolean :bold, "Bold this option", :default => false, :negate => 'un'
    
      # Tail options
    
      # When any of the simpler notations are suffixed with a '_' 
      # character, the short option is always suppressed.
      boolean_ :debug, "Prints out extra debugging output."
    
      # The '_' characters are replaced with '-' in flags, so the 
      # following creates a '--[no-]color' flag.
      boolean_ :color, "Turns on/off coloring in the output. Defalt is on." do
        negate
        default true
        validate do
          foo.command.alter do
            printer :standard, :colored => false
          end
        end
      end
    
      # Adds the standard -h/--help option.
      # Should skip the '-h' flag if already set.
      help  # Automatically adds the description if not passed an argument. You can supply your own
    
      # Adds the --version option.
      version "Foo: #{FOO_VERSION}"
    
      # Now, add some validation for any addtional arguments
      # that are left over after the parsing the options.
      arguments do
        metaname 'ARGS'
        count 1..10
        validate do |args, options|
          if args.empty?
            die "You have to pass in empty arguments that do nothing!"
          end
          if args.count == 10
            die "Whoa there!  You're going argument crazy!"
          end
        end
      end
    end
    
    if __FILE__ == $0
      # Parses and validates the options.
      args =  ['--prefix', '{', 
               '--suffix', '}',
               '--words', 'high', 'there', 'you', '-', 
               # The '-' stops parsing this option, so that:
               'handsom', 'devil',
               'http://not.posting.here', # will be regular arguments
               '-c', '3', # Count
               '--', # Stops parsing all arguments
               '-h', '--help', '-v', '--version' # Ignored
              ]
      result = foo_cmd.parse!(args)
      
      require 'pp'
      pp result[:prefix]        # => '{'
      pp result[:suffix]        # => '}'
      pp result[:count]         # => 3
      pp result[:bold]          # => false
      pp result[:words]         # => ['high', 'there', 'you']
      pp result.args            # => ['handsom', 'devil',
                                #     'http://not.posting.here',
                                #     '-h', '--help', '-v', '--version']
      pp result.options         # => {:prefix => '{', :suffix => '}'
                                #     :count => 3, :bold => false,
                                #     :words => ['high', 'there', 'you'],
                                #     :debug => false, :color => true}
      
      # Now, call the command that does the actual work.
      # This passes the foo_cmd.options and the foo_cmd.args
      # as arguments to the executors 'execute!' method.
      #
      # This allows you to easily associate command classes with
      # commands, without resorting to a hash or combining
      # execution logic with command parsing logic.
      foo_cmd.execute!(args)    # {high,there,you,foo}
                                # {high,there,you,foo}
                                # {high,there,you,foo}
                                # and handsom devil http://not.posting.here -h --help -v --verbose
      
    end

### Super Commands

You can also combine multiple choices into an uber-choice, creating
commands that look a lot like git or subversion.

First, we create another command.

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
    
We can now create our super command.

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
    

### TODO: Output Printing
