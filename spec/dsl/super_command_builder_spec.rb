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
        @builder.command :foo do |foo|
          foo.boolean :count, "The count"
        end

        @command.listing.should have(1).item
      end

      it "should add the command builder to the command_builders" do
        o = @builder.command :foo do |foo|
          foo.integer :size, "The size"
        end

        @command.command_builders[:foo].should be(o.builder)
      end

      it "should finalize the builder for the command" do
        o = @builder.command :foo
        o.printer.should_not be(nil)
      end
    end

    describe :finalize! do
      it "should set the printer if not already set"
    end
  end
end
