require 'spec_helpers'
require 'choosy/printing/help_printer'
require 'choosy/command'

module Choosy::Printing
  describe HelpPrinter do
    before :each do
      @h = HelpPrinter.new
    end

    it "should know the width of the screen, if possible, or set a default" do
      @h.columns.should satisfy {|c| c >= HelpPrinter::DEFAULT_COLUMN_COUNT }
    end

    it "should know the lenght the screen, if possible, or set a default" do
      @h.lines.should satisfy {|l| l >= HelpPrinter::DEFAULT_LINE_COUNT }
    end
  end
end
