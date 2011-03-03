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
        foo.boolean :evaluate, "The evaluation"
        foo.integer :count, "The count"
        foo.boolean :debug, "Debug output"
        foo.version "1.2"
        foo.help
      end
      @h = @c.printer
    end

    it "should now how to format a usage string" do
      @h.color.disable!
      o = capture { @h.print_usage(@c) }

      o.should eql("usage: foo [-e|--evaluate] [-c|--count=COUNT] [--debug]
        [--version] [-h|--help]")
    end

    it "should write a header, properly colored" do
      o = capture { @h.print_header("option") }
      o.should eql("e1[me34[moptione0[m")
    end

    it "should print out any commands that are present"
  end
end
