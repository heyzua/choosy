require 'spec_helpers'
require 'choosy/printing/base_printer'
require 'choosy/command'

module Choosy::Printing
  class PrintHelper
    include BasePrinter
  end
  
  describe BasePrinter do
    before :each do
      @b = Choosy::Command.new(:cmd).builder
      @p = PrintHelper.new
    end

    describe "for the usage line" do
      it "should format a full boolean option" do
        o = @b.boolean :bold, "bold"
        @p.usage_option(o).should eql("[-b|--bold]")
      end

      it "should format a partial boolean option" do
        o = @b.boolean_ :bold, "bold"
        @p.usage_option(o).should eql('[--bold]')
      end

      it "should format a short boolean option" do
        o = @b.option :bold do
          short '-b'
        end
        @p.usage_option(o).should eql('[-b]')
      end

      it "should format a negation of a boolean option" do
        o = @b.boolean :bold, "Bold!!" do
          negate 'un'
        end
        @p.usage_option(o).should eql('[-b|--bold|--un-bold]')
      end

      it "should format a full single option" do
        o = @b.single :color, "color"
        @p.usage_option(o).should eql('[-c|--color=COLOR]')
      end

      it "should format a parial boolean option" do
        o = @b.single_ :color, "color"
        @p.usage_option(o).should eql('[--color=COLOR]')
      end
      
      it "shoudl format a full multiple option" do 
        o = @b.multiple :colors, "c"
        @p.usage_option(o).should eql('[-c|--colors COLORS+]')
      end

      it "should format a partial multiple option" do
        o = @b.multiple_ :colors, "c"
        @p.usage_option(o).should eql('[--colors COLORS+]')
      end
    end

    describe "for the option line" do
      it "should format a full boolean option" do
        o = @b.boolean :bold, "b"
        @p.regular_option(o).should eql('-b, --bold')
      end

      it "should format a partial boolean option" do
        o = @b.boolean_ :bold, "b"
        @p.regular_option(o).should eql('    --bold')
      end

      it "should format a short boolean option" do
        o = @b.option :bold do |b|
          b.short '-b'
        end

        @p.regular_option(o).should eql('-b')
      end

      it "should format a negation of an option" do
        o = @b.boolean :bold, "Bold" do
          negate 'un'
        end

        @p.regular_option(o).should eql('-b, --[un-]bold')
      end

      it "should format a full single option" do
        o = @b.single :color, "color"
        @p.regular_option(o).should eql('-c, --color COLOR')
      end

      it "should format a partial single option" do
        o = @b.single_ :color, "color"
        @p.regular_option(o).should eql('    --color COLOR')
      end

      it "should format a full multiple option" do
        o = @b.multiple :colors, "colors"
        @p.regular_option(o).should eql('-c, --colors COLORS+')
      end

      it "should format a partial multiple option" do
        o = @b.multiple_ :colors, "colors"
        @p.regular_option(o).should eql('    --colors COLORS+')
      end
    end
  end
end

