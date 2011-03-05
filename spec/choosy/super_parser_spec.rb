require 'spec_helpers'
require 'choosy/super_parser'
require 'choosy/super_command'

module Choosy
  class SuperParserBuilder
    attr_reader :super
    
    def initialize
      @super = Choosy::SuperCommand.new :super
      @parsimonious = false
    end

    def command(name)
      @super.alter do
        command name do |c|
          yield c if block_given?
        end
      end
      self
    end

    def single(name)
      @super.alter do
        single name, name.to_s
      end
      self
    end

    def parse!(*args)
      parser = build
      parser.parse!(args)
    end

    def parsimonious!
      @parsimonious = true
    end 

    def build
      SuperParser.new(@super, @parsimonious)
    end
  end

  describe SuperParser do
    before :each do
      @p = SuperParserBuilder.new
    end

    describe "without any subcommands" do
      it "should fail with a regular global options" do
        attempting {
          @p.single(:count).parse!('--count', '5')
        }.should raise_error(Choosy::SuperParseError, /requires a command/)
      end

      it "should fail on unrecognized subcommands" do
        attempting {
          @p.single(:count).parse!('baz')
        }.should raise_error(Choosy::SuperParseError, /unrecognized command: 'baz'/)
      end

      it "should fail on unrecognized options" do
        attempting {
          @p.parse!('--here')
        }.should raise_error(Choosy::SuperParseError, /unrecognized option: '--here'/)
      end

      it "should raise a HelpCalled error when a help command is defined" do
        @p.super.builder.help
        attempting {
          @p.parse!()
        }.should raise_error(Choosy::HelpCalled, :SUPER_COMMAND)
      end
    end

    describe "with subcommands" do
      describe "being liberal" do
        it "should be able to parse a single subcommand" do
          @p.command(:bar).parse!('bar').subresults.should have(1).item
        end

        it "should merge parent option with child commands" do
          @p.single(:count).command(:bar).parse!('bar').subresults[0].options.should eql({:count => nil})
        end

        it "should merge parent option value with child" do
          @p.single(:count).command(:bar).parse!('bar', '--count', '3').subresults[0].options.should eql({:count => '3'})
        end
          
        it "should collect other names of commands as arguments" do
          @p.command(:bar).command(:baz).parse!('bar', 'baz').subresults.should have(1).item
        end
      end

      describe "being parsimonious" do
        before :each do
          @p.parsimonious!
        end

        it "should parse separate commands" do
          @p.command(:bar).command(:baz).parse!('bar', 'baz').subresults.should have(2).items
        end
      end
    end
  end
end
