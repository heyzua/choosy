require 'spec_helpers'
require 'choosy/printing/manpage'
require 'choosy/command'

module Choosy::Printing
  describe Manpage do
    before :each do
      @man = Manpage.new
      @cmd = Choosy::Command.new(:manpage)
    end

    it "should format a simple header" do
      @cmd.alter do
        header 'Option'
      end

      @man.format_header(@cmd.listing[0])
      @man.buffer.should eql(".SH Option\n")
    end

    it "should format the usage correctly" do
      @cmd.alter do
        boolean :bold, "Bold?"
        version "1.0"
        help

        arguments do
          metaname 'MANS'
        end
      end

      @man.format_usage(@cmd)
      @man.buffer.should eql(".SH Synopsis:
.B manpage
[\\-b|\\-\\-bold] [\\-\\-version] [\\-h|\\-\\-help] MANS\n")
    end

    it "should format format a paragraph correctly" do
      @cmd.alter do
        para "This is a paragraph"
      end

      @man.format_para(@cmd.listing[0])
      @man.buffer.should eql("This is a paragraph\n")
    end

    it "should format an option correctly" do
      @cmd.alter do
        integer :count, "The count goes here"
      end

      @man.format_option(@cmd.listing[0])
      @man.buffer.should eql(".BI \\-c, \\-\\-count COUNT
The count goes here\n")
    end

    it "should not add the .TP twice if already present" do
      @cmd.alter do
        integer :height, "The height"
        integer :width, "The width"
      end

      @man.format_listing(@cmd)
      @man.buffer.should eql(".TP
.BI \\-h, \\-\\-height HEIGHT
The height
.BI \\-w, \\-\\-width WIDTH
The width\n")
    end

    it "should format the preamble header" do
      @cmd.alter do
        summary "This is a summary - brief"
        integer :count, "the count"
      end

      @man.format_preamble(@cmd)
      @man.buffer.should eql(".TH manpage(1)
.SH Name:
manpage \\- This is a summary \\- brief\n")
    end

    it "should format a command correctly" do
      @cmd.alter do
        summary "This is a summary"
      end

      @man.format_command(@cmd)
      @man.buffer.should eql("\\fImanpage\\fP\tThis is a summary\n")
    end
  end
end
