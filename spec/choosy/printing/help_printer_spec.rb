require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @c = Choosy::Command.new :foo do |foo|
        foo.printer :standard, :color => true, :headers => [:bold, :blue]
        foo.summary "This is a fairly long summary that should wrap around the whole screen at least once, so that I can test whether it's propertly formatted"

        foo.header 'DESCRIPTION'
        foo.para 'This is a description of this command that should span'
        foo.para 'Multiple lines and carry itself beyond the average line length when actually called out from the unit tests itself so that we can correctly guage the line wrapping.'

        foo.header 'OPTIONS'
        foo.boolean :evaluate, "The evaluation of some boolean something or other that really should span at least 3 lines of continuous text for testing the output of the option command."
        foo.integer :count, "The count of something that should also really span multiple lines, if possible."
        foo.boolean_ :debug, "Debug output"
        foo.version "1.2"
        foo.help
      end
      @h = @c.printer
    end

    it "should now how to format a usage string" do
      @h.color.disable!
      @h.columns = 60
      o = capture { @h.print_usage(@c) }

      o.should eql("usage: foo [-e|--evaluate] [-c|--count=COUNT] [--debug]
           [--version] [-h|--help]\n")
    end

    it "should write a header, properly colored" do
      o = capture { @h.print_header("option") }
      o.should eql("\e[1m\e[34moption\e[0m")
    end

    it "should print out a formatted header" do
      o = capture { @h.print_element(@c.listing[0]) }
      o.should eql("\n\e[1m\e[34mDESCRIPTION\e[0m\n")
    end

    it "should print out a formatting element correctly" do
      o = capture { @h.print_element(@c.listing[1]) }
      o.should eql("\n  This is a description of this command that should span\n")
    end

    it "should wrap lines in a paragraph correctly" do
      @h.columns = 70
      o = capture { @h.print_element(@c.listing[2]) }
      o.should eql("\n  Multiple lines and carry itself beyond the average line length when
  actually called out from the unit tests itself so that we can
  correctly guage the line wrapping.\n")
    end

    it "should print out an option on multiple lines" do
      @h.columns = 70
      o = capture { @h.print_option(@c.listing[4], '-e, --evaluate', ' ' * 20) }
      o.should eql('  -e, --evaluate    The evaluation of some boolean something or other
                    that really should span at least 3 lines of
                    continuous text for testing the output of the 
                    option command.
')
    end

    it "should print out everything" do
      @h.columns = 70
      @h.print!(@c)
    end

    it "should print out any commands that are present"
  end
end
