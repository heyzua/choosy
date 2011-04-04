require 'spec_helpers'
require 'choosy/command'
require 'choosy/super_command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @c = Choosy::Command.new :foo do
        summary "This is a fairly long summary that should wrap around the whole screen at least once, so that I can test whether it's properly formatted"

        heading 'DESCRIPTION'
        para 'This is a description of this command that should span'
        para 'Multiple lines and carry itself beyond the average line length when actually called out from the unit tests itself so that we can correctly guage the line wrapping.'

        heading 'OPTIONS'
        boolean :evaluate, "The evaluation of some boolean something or other that really should span at least 3 lines of continuous text for testing the output of the option command."
        integer_ :count, "The count of something that should also really span multiple lines, if possible."
        boolean_ :debug, "Debug output"
        version "1.2"
        help

        arguments do
          metaname 'FOOS'
          count 0..3
        end
      end

      @b = @c.builder

      @s = Choosy::SuperCommand.new :super do
        printer :standard, :color => true, :heading_styles => [:bold, :blue]
        command @c
        metaname 'CMDS'

        boolean :bold, "Bold"
      end

      @h = @s.printer
    end

    describe :format_prologue do
      it "should know how to format a regular command" do
        @h.color.disable!
        @h.columns = 60
        @h.format_prologue(@c)

        @h.buffer.should eql("Usage: foo [-e|--evaluate] [--count=COUNT] [--debug] [--version]
           [-h|--help] FOOS\n\n")
      end

      it "should know how to format a super command" do
        @h.color.disable!
        @h.columns = 60
        @h.format_prologue(@s)

        @h.buffer.should eql("Usage: super [-b|--bold] CMDS\n\n")
      end
    end

    it "should write a header, properly colored" do
      @h.format_header("option")
      @h.buffer.should eql("\e[34m\e[1moption\e[0m")
    end

    it "should print out a formatted header" do
      @h.format_element(@c.listing[0])
      @h.buffer.should eql("\n\e[34m\e[1mDESCRIPTION\e[0m\n\n")
    end

    it "should print out a formatting element correctly" do
      @h.format_element(@c.listing[1])
      @h.buffer.should eql("  This is a description of this command that should span\n\n")
    end

    it "should wrap lines in a paragraph correctly" do
      @h.columns = 70
      @h.format_element(@c.listing[2])
      @h.buffer.should eql("  Multiple lines and carry itself beyond the average line length when
  actually called out from the unit tests itself so that we can
  correctly guage the line wrapping.\n\n")
    end

    it "should print out an option on multiple lines" do
      @h.columns = 70
      @h.format_option(@c.listing[4], '-e, --evaluate', ' ' * 20)
      @h.buffer.should eql('  -e, --evaluate    The evaluation of some boolean something or other
                    that really should span at least 3 lines of
                    continuous text for testing the output of the
                    option command.
')
    end

    it "should print out an option correctly that only has a single line" do
      @h.columns = 70
      @h.format_option(@c.listing[5], "      \e[1m--count\e[0m COUNT", ' ' * 23)
      @h.buffer.should eql("        \e[1m--count\e[0m COUNT  The count of something that should also really
                       span multiple lines, if possible.
")
    end

    it "should print out any commands that are present" do
      @h.columns = 70
      @h.format_command(@c, 'foo', '         ')
      @h.buffer.should eql("  foo    This is a fairly long summary that should wrap around the
         whole screen at least once, so that I can test whether it's
         properly formatted\n")
    end

    it "should format a regular option with color, when not disabled" do
      @h.regular_option(@c.listing[5]).should eql("    \e[1m--count\e[0m COUNT")
    end

    it "should format a regular option without color when color is disabled" do
      @h.color.disable!
      @h.regular_option(@c.listing[5]).should eql("    --count COUNT")
    end
  end
end
