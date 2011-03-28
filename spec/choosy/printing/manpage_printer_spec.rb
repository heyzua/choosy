require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/manpage_printer'

module Choosy::Printing
  describe ManpagePrinter do
    before :each do
      @man = ManpagePrinter.new
      @cmd = Choosy::Command.new(:manpage)
    end

    def output
      @man.manpage.buffer.join("\n")
    end

    describe "for the name segment" do
      it "should not print anything if no summary is present" do
        @man.format_name(@cmd)
        output.should eql('')
      end

      it "should print out the summary" do
        @cmd.alter do 
          summary 'summary goes here'
        end
        @man.format_name(@cmd)
        output.should eql('.SH "NAME"
manpage \\- summary goes here')
      end
    end

    describe "for the synopsis" do
      it "should add the synopsis correctly" do
        @cmd.alter do
          boolean :bold, "bold"
          integer :long_option_goes_here, "long"
          integer :shorter_option, "short"
          arguments do
            metaname '[ARGS+++]'
          end
        end
        @man.columns = 60
        @man.format_synopsis(@cmd)
        output.should eql('.SH "SYNOPSIS"
.nf
manpage [\\-b|\\-\\-bold]
        [\\-l|\\-\\-long\\-option\\-goes\\-here=LONG_OPTION_GOES_HERE]
        [\\-s|\\-\\-shorter\\-option=SHORTER_OPTION] [ARGS+++]
.fi')
      end
    end

    it "should format an option" do
      o = @cmd.builder.integer :opt, 'option line here.'
      @man.format_option(o, @man.regular_option(o), '        ')
      output.should eql('.TP 8
\\fI\\-o\\fP, \\fI\\-\\-opt\\fP OPT
option line here.')
    end

    it "should format a command" do
      @cmd.alter do
        summary 'this is a summary'
      end
      @man.format_command(@cmd, 'cmd', '    ')
      output.should eql('.TP 4
\fIcmd\fP
this is a summary')
    end

    it "should format a heading correctly" do
      @cmd.alter do
        heading 'here'
      end
      @man.format_element(@cmd.listing[0])
      output.should eql('.SH "HERE"')
    end

    it "should format a regular paragraph" do
      @cmd.alter do
        para 'paragraph'
      end
      @man.format_element(@cmd.listing[0])
      output.should eql(".P\nparagraph")
    end

    it "should format an empty paragraph" do
      @cmd.alter do
        para
      end
      @man.format_element(@cmd.listing[0])
      output.should eql('.P')
    end
  end
end
