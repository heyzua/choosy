require 'spec_helpers'
require 'choosy/dsl/command_builder'
require 'choosy/command'
require 'choosy/converter'
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
      @builder = @command.builder
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
    end#executor

    describe :help do
      it "should allow for a no arg" do
        h = @builder.help
        h.description.should eql("Show this help message")
      end

      it "should allow you to set the message" do
        h = @builder.help 'Help message'
        h.description.should eql('Help message')
      end

      it "should throw a HelpCalled upon validation" do
        h = @builder.help
        attempting {
          h.validation_step.call
        }.should raise_error(Choosy::HelpCalled)
      end
    end#help

    describe :arguments do
      it "should fail if there is no block given" do
        attempting {
          @builder.arguments
        }.should_not raise_error
      end

      it "should pass in the block correctly" do
        @builder.arguments do
          metaname 'ARGS'
        end
        @command.arguments.metaname.should eql('ARGS')
      end

      it "should pass in the arguments to validate" do
        @builder.arguments do
          validate do |args, options|
            raise RuntimeError, "called"
          end
        end
        attempting {
          @command.arguments.validation_step.call([2, 2, 3], nil)
        }.should raise_error(RuntimeError, "called")
      end
    end#arguments
  end
end
