require 'choosy/errors'
require 'choosy/parser'
require 'choosy/base_command'
require 'choosy/dsl/super_command_builder'

module Choosy
  class SuperCommand < BaseCommand
    attr_reader :command_builders

    def command_builders
      @command_builders ||= {}
    end

    def commands
      @command_bulders.values.map {|b| b.command }
    end

    protected
    def create_builder
      Choosy::DSL::SuperCommandBuilder.new(self)
    end
  end
end
