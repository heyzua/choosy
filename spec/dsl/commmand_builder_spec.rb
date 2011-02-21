require 'spec_helpers'
require 'choosy/dsl/command_builder'
require 'choosy/command'
require 'choosy/errors'

module Choosy::DSL
  class FakeExecutor
    attr_reader :options, :args
    def execute!(options, args)
      @options = options
      @args = args
    end
  end


  describe CommandBuilder do
    before :each do
      @command = Choosy::Command.new(:cmd)
      @builder = CommandBuilder.new(@command)
    end

    describe :executor do
      it "should set the executor in the command" do
        @builder.executor FakeExecutor.new
        @command.executor.should be_a(FakeExecutor)
      end

      it "should handle proc arguments" do
        @builder.executor {|opts, args| puts "hi"}
        @command.executor.should_not be(nil)
      end

      it "should raise an error if the executor is nil" do
        attempting {
          @builder.executor nil
        }.should raise_error(Choosy::ConfigurationError, /executor was nil/)
      end

      it "should raise an error if the executor class doesn't have an 'execute!' method" do
        attempting {
          @builder.executor Array.new
        }.should raise_error(Choosy::ConfigurationError, /'execute!'/)
      end
    end

    describe :printer do
      it "should know how to set the default printer"
      it "should understand how to set custom printers"
      it "should fail when the printer doesn't implement 'print!'"
      it "should know how to turn off color"
      it "should know how to turn on color"
    end

    describe :summary do
      it "should set the summary for this command" do
        @builder.summary "This is a summary"
        @command.summary.should eql("This is a summary")
      end
    end

    describe :desc do
      it "should set the summary for this command" do
        @builder.desc "This is a description"
        @command.description.should match(/This is/)
      end
    end
  end
end
