require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @h = HelpPrinter.new
      @c = Choosy::Command.new :foo do |foo|
        foo.summary "This is a summary of a command."
        foo.desc <<EOF
This is a description of this command that should span

multiple lines and carry itself beyond the average line length when actually called out from the unit tests itself so that we can correctly guage the line wrapping.
EOF
        foo.separator
        foo.boolean :evaluate, "The evaluation"
        foo.integer :count, "The count"
        foo.separator

        foo.separator 'Indifferent options:'
        foo.boolean :debug, "Debug output"
        foo.version "1.2"
        foo.help
      end
    end

    it "should know the width of the screen, if possible, or set a default [COULD BREAK ON YOUR MACHINE]" do
      @h.columns.should satisfy {|c| c >= HelpPrinter::DEFAULT_COLUMN_COUNT }
    end

    it "should know the lenght the screen, if possible, or set a default [COULD BREAK ON YOUR MACHINE]" do
      @h.lines.should satisfy {|l| l >= HelpPrinter::DEFAULT_LINE_COUNT }
    end

    it "should now how to format a usage string" do
      o = capture :stdout do
        @h.print_usage(@c)
      end

      o.should eql("Usage: foo [OPTIONS]\n")
    end

    it "should show the usage string if it accepts extra arguments" do
      @c.alter do |foo|
        foo.arguments do |args|
        end
      end

      o = capture :stdout do
        @h.print_usage(@c)
      end

      o.should eql("Usage: foo [OPTIONS] [ARGS]\n")
    end

    it "should print a newline on an empty separator" do
      o = capture :stdout do
        @h.print_separator("")
      end

      o.should eql("\n")
    end

    it "should print a line with separator text" do
      o = capture :stdout do
        @h.print_separator("this line")
      end

      o.should eql("this line\n")
    end

    it "should print out a command" do
      o = capture :stdout do
        @h.print_command(@c)
      end

      o.should eql("  foo\tThis is a summary of a command.\n")
    end

    it "should print the summary, if present" do
      o = capture :stdout do
        @h.print_summary(@c.summary)
      end

      o.should eql("This is a summary of a command.\n")
    end

    it "should print out an option on 2 lines." do
      o = capture :stdout do
        @h.print_option(@c.listing[2])
      end

      o.should eql("    -c, --count COUNT\n        The count\n")
    end
    
    it "should print out any commands that are present"

    it "should print out the description" do
      @h.columns = 80
      o = capture :stdout do
        @h.print_description(@c.description)
      end

      o.should eql(<<EOF
Description:
    This is a description of this command that should span

    multiple lines and carry itself beyond the average line length when actually
    called out from the unit tests itself so that we can correctly guage the
    line wrapping.
EOF
                  )
    end
  end
end
