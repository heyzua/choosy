require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/formatter'

module Choosy::Printing
  class FormatterTest
    include Formatter
  end

  describe Formatter do
    before :each do
      @formatter = FormatterTest.new
      @command = Choosy::Command.new :cmd
      @builder = @command.builder
    end

    describe "for the usage line" do
      it "should format a full boolean option" do
        o = @builder.boolean :bold, "bold"
        @formatter.usage_option(o).should eql("[-b|--bold]")
      end

      it "should format a partial boolean option" do
        o = @builder.boolean_ :bold, "bold"
        @formatter.usage_option(o).should eql('[--bold]')
      end

      it "should format a short boolean option" do
        o = @builder.option :bold do |b|
          b.short '-b'
        end
        @formatter.usage_option(o).should eql('[-b]')
      end

      it "should format a negation of a boolean option"

      it "should format a full single option" do
        o = @builder.single :color, "color"
        @formatter.usage_option(o).should eql('[-c|--color=COLOR]')
      end

      it "should format a parial boolean option" do
        o = @builder.single_ :color, "color"
        @formatter.usage_option(o).should eql('[--color=COLOR]')
      end
      
      it "shoudl format a full multiple option" do 
        o = @builder.multiple :colors, "c"
        @formatter.usage_option(o).should eql('[-c|--colors COLORS+]')
      end

      it "should format a partial multiple option" do
        o = @builder.multiple_ :colors, "c"
        @formatter.usage_option(o).should eql('[--colors COLORS+]')
      end
    end

    describe "for the option line" do
      it "should format a full boolean option" do
        o = @builder.boolean :bold, "b"
        @formatter.regular_option(o).should eql('-b, --bold')
      end

      it "should format a partial boolean option" do
        o = @builder.boolean_ :bold, "b"
        @formatter.regular_option(o).should eql('    --bold')
      end

      it "should format a short boolean option" do
        o = @builder.option :bold do |b|
          b.short '-b'
        end

        @formatter.regular_option(o).should eql('-b')
      end

      it "should format a negation of an option"

      it "should format a full single option" do
        o = @builder.single :color, "color"
        @formatter.regular_option(o).should eql('-c, --color COLOR')
      end

      it "should format a partial single option" do
        o = @builder.single_ :color, "color"
        @formatter.regular_option(o).should eql('    --color COLOR')
      end

      it "should format a full multiple option" do
        o = @builder.multiple :colors, "colors"
        @formatter.regular_option(o).should eql('-c, --colors COLORS+')
      end

      it "should format a partial multiple option" do
        o = @builder.multiple_ :colors, "colors"
        @formatter.regular_option(o).should eql('    --colors COLORS+')
      end
    end
  end
end
