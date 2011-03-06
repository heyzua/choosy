require 'spec_helpers'
require 'choosy/command'
require 'choosy/super_command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @c = Choosy::Command.new :foo do
        summary "This is a fairly long summary that should wrap around the whole screen at least once, so that I can test whether it's properly formatted"

        header 'DESCRIPTION'
        para 'This is a description of this command that should span'
        para 'Multiple lines and carry itself beyond the average line length when actually called out from the unit tests itself so that we can correctly guage the line wrapping.'

        header 'OPTIONS'
        boolean :evaluate, "The evaluation of some boolean something or other that really should span at least 3 lines of continuous text for testing the output of the option command."
        integer :count, "The count of something that should also really span multiple lines, if possible."
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
        printer :standard, :color => true, :header_styles => [:bold, :blue]
        command @c
        metaname 'CMDS'

        boolean :bold, "Bold"
      end

      @h = @s.printer
    end

    describe :print_usage do
      it "should know how to format a regular command" do
        @h.color.disable!
        @h.columns = 60
        @h.print_usage(@c)

        @h.buffer.should eql("Usage: foo [-e|--evaluate] [-c|--count=COUNT] [--debug]
           [--version] [-h|--help] FOOS\n")
      end

      it "should know how to format a super command" do
        @h.color.disable!
        @h.columns = 60
        @h.print_usage(@s)

        @h.buffer.should eql("Usage: super [-b|--bold] CMDS\n")
      end
    end

    it "should write a header, properly colored" do
      @h.print_header("option")
      @h.buffer.should eql("\e[34m\e[1moption\e[0m")
    end

    it "should print out a formatted header" do
      @h.print_element(@c.listing[0])
      @h.buffer.should eql("\n\e[34m\e[1mDESCRIPTION\e[0m\n")
    end

    it "should print out a formatting element correctly" do
      @h.print_element(@c.listing[1])
      @h.buffer.should eql("\n  This is a description of this command that should span\n")
    end

    it "should wrap lines in a paragraph correctly" do
      @h.columns = 70
      @h.print_element(@c.listing[2])
      @h.buffer.should eql("\n  Multiple lines and carry itself beyond the average line length when
  actually called out from the unit tests itself so that we can
  correctly guage the line wrapping.\n")
    end

    it "should print out an option on multiple lines" do
      @h.columns = 70
      @h.print_option(@c.listing[4], '-e, --evaluate', ' ' * 20)
      @h.buffer.should eql('  -e, --evaluate    The evaluation of some boolean something or other
                    that really should span at least 3 lines of
                    continuous text for testing the output of the
                    option command.
')
    end

    it "should print out any commands that are present" do
      @h.columns = 70
      @h.print_command(@c, 'foo', '         ')
      @h.buffer.should eql("  foo    This is a fairly long summary that should wrap around the
         whole screen at least once, so that I can test whether it's
         properly formatted\n")
    end

    describe "for the usage line" do
      it "should format a full boolean option" do
        o = @b.boolean :bold, "bold"
        @h.usage_option(o).should eql("[-b|--bold]")
      end

      it "should format a partial boolean option" do
        o = @b.boolean_ :bold, "bold"
        @h.usage_option(o).should eql('[--bold]')
      end

      it "should format a short boolean option" do
        o = @b.option :bold do
          short '-b'
        end
        @h.usage_option(o).should eql('[-b]')
      end

      it "should format a negation of a boolean option" do
        o = @b.boolean :bold, "Bold!!" do
          negate 'un'
        end
        @h.usage_option(o).should eql('[-b|--bold|--un-bold]')
      end

      it "should format a full single option" do
        o = @b.single :color, "color"
        @h.usage_option(o).should eql('[-c|--color=COLOR]')
      end

      it "should format a parial boolean option" do
        o = @b.single_ :color, "color"
        @h.usage_option(o).should eql('[--color=COLOR]')
      end
      
      it "shoudl format a full multiple option" do 
        o = @b.multiple :colors, "c"
        @h.usage_option(o).should eql('[-c|--colors COLORS+]')
      end

      it "should format a partial multiple option" do
        o = @b.multiple_ :colors, "c"
        @h.usage_option(o).should eql('[--colors COLORS+]')
      end
    end

    describe "for the option line" do
      it "should format a full boolean option" do
        o = @b.boolean :bold, "b"
        @h.regular_option(o).should eql('-b, --bold')
      end

      it "should format a partial boolean option" do
        o = @b.boolean_ :bold, "b"
        @h.regular_option(o).should eql('    --bold')
      end

      it "should format a short boolean option" do
        o = @b.option :bold do |b|
          b.short '-b'
        end

        @h.regular_option(o).should eql('-b')
      end

      it "should format a negation of an option" do
        o = @b.boolean :bold, "Bold" do
          negate 'un'
        end

        @h.regular_option(o).should eql('-b, --[un-]bold')
      end

      it "should format a full single option" do
        o = @b.single :color, "color"
        @h.regular_option(o).should eql('-c, --color COLOR')
      end

      it "should format a partial single option" do
        o = @b.single_ :color, "color"
        @h.regular_option(o).should eql('    --color COLOR')
      end

      it "should format a full multiple option" do
        o = @b.multiple :colors, "colors"
        @h.regular_option(o).should eql('-c, --colors COLORS+')
      end

      it "should format a partial multiple option" do
        o = @b.multiple_ :colors, "colors"
        @h.regular_option(o).should eql('    --colors COLORS+')
      end
    end
  end
end
