require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @h = HelpPrinter.new
      @c = Choosy::Command.new :foo do |foo|
        foo.summary "This is a summary of a command."
        foo.para <<EOF
This is a description of this command that should span

multiple lines and carry itself beyond the average line length when actually called out from the unit tests itself so that we can correctly guage the line wrapping.
EOF
        foo.boolean :evaluate, "The evaluation"
        foo.integer :count, "The count"

        foo.header 'Indifferent options:'
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

      o.should eql("USAGE: foo [OPTIONS]\n")
    end

    it "should show the usage string if it accepts extra arguments" do
      @c.alter do |foo|
        foo.arguments do |args|
        end
      end

      o = capture :stdout do
        @h.print_usage(@c)
      end

      o.should eql("USAGE: foo [OPTIONS] [ARGS]\n")
    end

    it "should print out a command" do
      o = capture :stdout do
        @h.print_command(@c)
      end

      o.should eql("  foo\tThis is a summary of a command.\n")
    end

    it "should print out an option on 2 lines." do
      o = capture :stdout do
        @h.print_option(@c.listing[2])
      end

      o.should eql("  -c, --count COUNT\n       The count\n")
    end
    
    it "should print out any commands that are present"

  end
end
