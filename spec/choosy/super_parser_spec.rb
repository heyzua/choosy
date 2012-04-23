module Choosy
  class SuperParserBuilder
    attr_reader :super
    
    def initialize
      @super = Choosy::SuperCommand.new :super
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
      @super.alter do
        parsimonious
      end
    end

    def build
      SuperParser.new(@super)
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
        @p.super.builder.command :help
        attempting {
          @p.parse!()
        }.should raise_error(Choosy::HelpCalled, Choosy::DSL::SuperCommandBuilder::SUPER)
      end

      it "should push the default command on the stack to parse" do
        @p.command :bar
        @p.super.alter do 
          default :bar
        end

        @p.parse!().subresults.should have(1).item
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
          @p.command(:bar) do |c|
            c.arguments
          end.command(:baz).parse!('bar', 'baz').subresults.should have(1).item
        end

        it "should fail when the first command doesn't take arguments" do
          attempting {
            @p.command(:bar).command(:baz).parse!('bar', 'baz')
          }.should raise_error(Choosy::ValidationError, /bar: no arguments allowed: baz/)
        end
      end

      describe "being parsimonious" do
        before :each do
          @p.parsimonious!
        end

        it "should parse separate commands" do
          @p.command(:bar).command(:baz).parse!('bar', 'baz').subresults.should have(2).items
        end

        it "should be able to read global options" do
          @p.super.alter do
            version 'this'
          end
          attempting {
            @p.command(:bar).parse!('bar', '--version')
          }.should raise_error(Choosy::VersionCalled)
        end

        it "should call 'help' with the appropriate args when defined" do
          @p.super.alter do
            command :help
          end

          attempting {
            @p.command(:bar).parse!('help', 'bar')
          }.should raise_error(Choosy::HelpCalled, :bar)
        end
      end
    end
  end
end
