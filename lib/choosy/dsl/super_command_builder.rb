require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/command'

module Choosy::DSL
  class SuperCommandBuilder < BaseCommandBuilder
    def command(name)
      subcommand = Choosy::Command.new(name)
      yield subcommand.builder if block_given?
      subcommand.builder.finalize!

      @command.command_builders[name] = subcommand.builder
      @command.listing << subcommand
      subcommand
    end

    def finalize!
      # TODO: fill in
    end

    protected
    def create_printer
      # TODO: fill in
    end
  end
end
