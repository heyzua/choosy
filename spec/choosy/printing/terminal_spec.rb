require 'spec_helpers'
require 'choosy/printing/terminal'

module Choosy::Printing
  class TerminalTest
    include Terminal
  end

  describe Terminal do
    before :each do
      @t = TerminalTest.new
    end

    it "should know the width of the screen, if possible, or set a default [COULD BREAK ON YOUR MACHINE]" do
      @t.columns.should satisfy {|c| c >= Terminal::DEFAULT_COLUMN_COUNT }
    end

    it "should know the lenght the screen, if possible, or set a default [COULD BREAK ON YOUR MACHINE]" do
      @t.lines.should satisfy {|l| l >= Terminal::DEFAULT_LINE_COUNT }
    end
  end
end
