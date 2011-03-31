require 'spec_helpers'
require 'choosy/terminal'

module Choosy
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

    it "should allow for setting the column width" do
      @t.columns = 40
      @t.columns.should eql(40)
    end
  end
end
