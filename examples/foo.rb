#!/usr/bin/env ruby
##-
BEGIN {$VERBOSE = true}
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
##+
# foo.rb
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

$foo_cmd = Choosy::Command.new :foo do |foo|
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
      foo.entity.alter do
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
  result = $foo_cmd.parse!(args)
  
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
  $foo_cmd.execute!(args)    # {high,there,you,foo}
                            # {high,there,you,foo}
                            # {high,there,you,foo}
                            # and handsom devil http://not.posting.here -h --help -v --verbose
  
end
