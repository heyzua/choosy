require 'choosy/errors'
require 'choosy/base_command'
require 'choosy/dsl/command_builder'
require 'choosy/parser'
require 'choosy/verifier'

module Choosy
  class Command < BaseCommand
    attr_accessor :executor, :argument_validation
    
    def execute!(args)
      raise Choosy::ConfigurationError.new("No executor given for: #{name}") unless executor
      result = parse!(args)
      executor.call(result.options, result.args)
    end

    protected
    def create_builder
      Choosy::DSL::CommandBuilder.new(self)
    end

    def handle_help(hc)
      puts printer.print!(self)
    end

    def parse(args)
      parser = Parser.new(self)
      result = parser.parse!(args)

      verifier = Verifier.new
      verifier.verify!(result)
    
      result
    end
  end
end
