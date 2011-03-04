require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/help_printer'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @c = Choosy::Command.new :foo do |foo|
        foo.printer :standard, :color => true, :header_styles => [:bold, :blue]
        foo.summary "This is a fairly long summary that should wrap around the whole screen at least once, so that I can test whether it's properly formatted"

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
      @b = @c.builder
    end

    it "should now how to format a usage string" do
      @h.color.disable!
      @h.columns = 60
      @h.print_usage(@c)

      @h.buffer.should eql("Usage: foo [-e|--evaluate] [-c|--count=COUNT] [--debug]
           [--version] [-h|--help]\n")
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
        o = @b.option :bold do |b|
          b.short '-b'
        end
        @h.usage_option(o).should eql('[-b]')
      end

      it "should format a negation of a boolean option"

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

      it "should format a negation of an option"

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
