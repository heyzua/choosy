require 'spec_helpers'
require 'choosy/super_command'
require 'choosy/dsl/super_command_builder'

module Choosy::DSL
  describe SuperCommandBuilder do
    before :each do
      @command = Choosy::SuperCommand.new :superfoo
      @builder = @command.builder
    end

    describe :command do
      it "should add the command to the listing" do
        @builder.command :foo do
          boolean :count, "The count"
        end

        @command.listing.should have(1).item
      end

      it "should add the command builder to the command_builders" do
        o = @builder.command :foo do
          integer :size, "The size"
        end

        @command.command_builders[:foo].should be(o.builder)
      end

      it "should finalize the builder for the command" do
        o = @builder.command :foo
        o.printer.should_not be(nil)
      end

      it "should be able to accept a new command as an argument" do
        cmd = Choosy::Command.new :cmd do
          float :float, "Float"
        end
        @builder.command cmd
        @command.listing[0].should be(cmd)
      end

      it "should set the parent command on new commands" do
        cmd = @builder.command :foo
        cmd.parent.should be(@command)
      end

      it "should set the parent command on existing commands" do
        cmd = Choosy::Command.new :foo
        @builder.command cmd
        cmd.parent.should be(@command)
      end
    end
    
    describe :parsimonious do
      it "should not be parsimonous by default" do
        @command.parsimonious?.should be_false
      end

      it "should set parsimonious" do
        @builder.parsimonious
        @command.parsimonious?.should be_true
      end
    end

    describe :metaname do
      it "should set the super command's metaname for the subcommands" do
        @builder.metaname 'META'
        @command.metaname.should eql('META')
      end
    end

    describe :default do
      it "should set the default command" do
        @builder.default :foo
        @command.default_command.should eql(:foo)
      end
    end

    describe "standard options" do
      it "should also be able to set flags" do
        o = @builder.boolean :count, "The count"
        @command.option_builders[:count].entity.name.should eql(:count)
      end
    end

    describe :help do
      it "should create a help command when asked" do
        h = @builder.command :help
        @command.listing[0].should be(h)
      end

      it "should set the default summary of the help command" do
        h = @builder.command :help
        h.summary.should match(/Show the info/)
      end

      it "should st the summary of the command when given" do
        h = @builder.command :help do
          summary "Show this help message"
        end
        h.summary.should match(/Show this/)
      end

      describe "when validated" do
        it "should return the super command name when called without arguments" do
          h = @builder.command :help
          attempting {
            h.arguments.validation_step.call([])
          }.should raise_error(Choosy::HelpCalled, nil)
        end

        it "should return the name of the first argument when called, as a symbol" do
          h = @builder.command :help
          attempting {
            h.arguments.validation_step.call(['foo'])
          }.should raise_error(Choosy::HelpCalled, :foo)
        end
      end
    end
  end
end
