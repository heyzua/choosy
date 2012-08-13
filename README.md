# Choosy: Picking your Arguments Carefully

This is a small DSL library for creating command line clients in Ruby. It is largely inspired by the <a href="https://github.com/defunkt/choice">choice</a>, <a href="https://github.com/visionmedia/commander">commander</a>, and <a href="http://furius.ca/optcomplete/">optcomplete.py</a> libraries, though it makes some different design decisions than they do.  It is opinionated software.

This library should:

  - Make creating command line clients relatively easy.
  - Make creating supercommands like git, subversion, and gem easier.
  - Allow you to add validation logic for your arguments within the parsing phase.
  - Allowing for dependencies between options, so that you can more easily validate related options (i.e. if the<code>--bold</code> flag requires the <code>--font Arial</code> flag, then you should be able to ask for the <code>--font</code> option to be validated first, and then the <code>--bold</code> option.
  - Allow you to customize its output using your own formatting system, or provide several convenient defaults when you don't want to provide your own.

This library should never:

  - Interact with your execution logic.  You can attach executors to commands for convenience, but the execution phase should be delegated to you, not the parsing library.  Separation of concerns, people.
  - Rely on display or user interface libraries like Highline, since this is only for parsing command lines.
  - Pollute your namespaces with my DSL function names.  (I really, really hate it when libraries do this.)

# Examples

This example is a simple date and time tool.

    #!/usr/bin/env ruby

    # date-time
    require 'choosy'
    require 'time'

    class DateTimeCLI
      attr_reader :command

      def run!(args)
        @command = Choosy::Command.new :'date-time' do
          summary "This is a command that prints out the current time"

          executor do |args, options| # An executor can just be a simple block.
            if options[:utc]
              puts Time.now.utc.strftime(options[:format])
            else
              puts Time.now.strftime(options[:format])
            end
          end

          section "Description" do
            para "This tool prints out the current time, with some added effects"
          end

          section "Options" do
            boolean :utc, "Prints it using the UTC format"
            string  :format, "The format of the output" do
              default "%Y-%m-%d %H:%M:%S %z"
            end
          end

          help            # Enables the '-h|--help' option.
          version "1.0"   # Enables the '--version' option.
        end.execute!(args)
      end
    end

    if __FILE__ == $0
      DateTimeCLI.new.run!(ARGV)
    end

Another simple tool that lists directories.

    #!/usr/bin/env ruby

    # list-files
    require 'choosy'

    class ListFilesCLI
      attr_reader :command

      def run!(args)
        exe = self  # The following block will change 'self', so we capture context here.

        @command = Choosy::Command.new :'date-time' do
          summary "This is a command that lists files in directories"
          executor exe  # Commands need executors that implement 'execute!'.
                        # We're using 'self'.

          section "Description" do
            para "This tool prints out some information about directories"
          end

          section "Options" do
            integer :limit, "Limit the printed listing to a given number of files."
            boolean :dirs_only, "Only print out directories"
          end

          help            # Enables the '-h|--help' option.
          version "1.0"   # Enables the '--version' option.

          arguments do
            metaname 'PATH'   # What to display on the manpage
            count    0..1     # The number of items allowed, restricted here by a range.
          end
        end.execute!(args)
      end

      # Called by the command at the end of the 'run!'
      def execute!(args, options)
        limit = options[:limit] || 0
        paths = if args.empty?
                 ['.']
               else
                 args
               end

        paths.each do |path|
          Dir["#{path}/*"].each do |fname|
            puts fname

            limit -= 1
            if limit == 0
              return
            end
          end
        end
      end
    end

    if __FILE__ == $0
      ListFilesCLI.new.run!(ARGV)
    end

### Super Commands

You can also combine multiple choices into an uber-choice, creating commands that look a lot like git or subversion.

    #!/usr/bin/env ruby

    # git-wrapper
    require 'choosy'

    class GitExecutor
      def initialize(type)
        @type = type
      end

      def execute!(args, options)
        exec("git #{@type}")
      end
    end

    class GitWrapperCLI
      attr_reader :command

      def run!(args)
        exe = self  # The following block will change 'self', so we capture context here.

        @command = Choosy::SuperCommand.new :'git-wrapper' do
          summary "This is a command that lists files in directories"

          section "Description" do
            para "This tool prints out some information about directories"
          end

          section "Commands" do
            command :status do
              summary "Prints out the 'git status'"
              executor GitExecutor.new(:status)

              help
            end

            command :diff do
              summary "Prints out the 'git diff'"
              executor GitExecutor.new(:diff)

              help
            end
          end

          help            # Enables the '-h|--help' option.
          version "1.0"   # Enables the '--version' option.
        end.execute!(args)
      end
    end

    if __FILE__ == $0
      GitWrapperCLI.new.run!(ARGV)
    end

# Output Printing

Choosy allows you to customize the output printing of your documentation. It exposes the internal object model to any class that implements a <code>print!(command)</code> method.

The <code>:standard</code> printer that is the default for any command can also be customized to meet some of your needs:

    Choosy::Command.new :foo do
      printer :standard,              # The default printer
              :max_width => 80,       # Defaults to the column witdh of the terminal
              :color => true,         # Default is true
              :header_styles => [:bold, :green],  # Defaults to [:bold, :blue]
              :indent => '   ',       # Defaults to this width
              :offset => '  '         # Defaults to this width

      help "Show this help command."
    end

This above example sets some useful properties for the printer. First, the <code>:max\_width</code> limits the wrapping size on the console. By default, choosy tries to be smart and wrap to the currend column width, but you can introduce this hash parameter as a default max. Next, you can turn off and on color printing by setting <code>:color</code>. Color is on by default, so it's actually superfluous in this example -- just a demonstration of the syntax. The <code>:header\_styles</code> is an array of styles that will be applied to the headers for this document. By default, headers are <code>[:bold, :blue]</code>. Most of the ANSI colors and codes are supported, but check <code>lib/choosy/printing/color.rb</code> for additional options. The last two options given are actually formatting spacers in the output that you can customize: <code>:indent</code> is the default indent for commands and options; <code>:offset</code> is the distance between the options and commands to their associated descriptive text.

For those who want the nice, manpage experience, there's also the <code>:manpage</code> printer:

    Choosy::Command.new :foo do
      printer :manpage,
              :max_width => 80,                  # Same as :standard
              :color => true,                    # Same as :standard
              :header_styles => [:bold, :green], # Same as :standard
              :option_sytles => [:bold],         # Same as :standard
              :indent => '   ',                  # Same as :standard
              :offset => '  ',                   # Same as :standard
              :version => FOO_VERSION, # Will use the version name you specify, see below.
              :section => 1,           # Default is always '1'
              :date => '03/24/2011',   # Date you want displayed
              :manual => 'Foo Co.'     # The manual page group

      version FOO_VERSION # If you don't supply a version above, this will be used
    end

Because the library is super-awesome, the manpage will even be in color when piped to <code>less -R</code> (the default)! If you don't like the format of my manpage, feel free to implement your own using the <code>choosy/printing/manpage</code> class, a useful utility class for formatting manpage output correctly.

If you already have some templates that you'd like to use, there is also the <code>:erb</code> template that can be customized by writing a template of your choice:

    Choosy::Command.new :foo do
      printer :erb,
              :color => true,                 # Defaults to true
              :template => 'path/to/file.erb' # Required
    end

The ERB printer also accepts the <code>:color</code> option. The color is exposed via a <code>color</code> property in the template; the command is exposed by the <code>command</code> property.

Finally, because I don't want to tell you how to print your help, I also give you the option of supplying your own printer. Just create a class with a <code>print!(command)</code> method on that class, and it will be passed in the command that it should print the help for. I have supplied some code you may find useful in <code>choosy/terminal</code> that will help with things like finding commands and determining the column width of the terminal.

    class CustomPrinter
      def print!(command)
        puts "I got called on help for #{command.name}"
      end
    end

    Choosy::Command.new :foo do
      printer CustomPrinter.new
    end

