require 'choosy/errors'
require 'choosy/parser'
require 'choosy/parse_result'
require 'choosy/verifier'
require 'choosy/dsl/super_command_builder'

module Choosy
  class SuperParser
    attr_reader :terminals, :verifier

    def initialize(super_command)
      @super_command = super_command
      @verifier = Verifier.new
      generate_terminals
    end

    def parse!(args)
      result = parse_globals(args)
      unparsed = result.unparsed

      while unparsed.length > 0
        command_result = parse_command(unparsed, terminals)
        result.subresults << command_result
        
        unparsed = command_result.unparsed
      end

      result.subresults.each do |subresult|
        if subresult.command.name == Choosy::DSL::SuperCommandBuilder::HELP
          verifier.verify!(subresult)
        end
      end

      verifier.verify!(result)

      result.subresults.each do |subresult|
        subresult.options.merge!(result.options)
        verifier.verify!(subresult)
      end

      result
    end

    private
    def generate_terminals
      @terminals = []
      if @super_command.parsimonious?
        @super_command.commands.each do |c|
          @terminals << c.name.to_s
        end
      end
    end

    def parse_globals(args)
      result = SuperParseResult.new(@super_command)
      parser = Parser.new(@super_command, true, @terminals)
      parser.parse!(args, result)
      verifier.verify_special!(result)

      # if we found a global action, we should have hit it by now...
      if result.unparsed.length == 0
        if @super_command.command_builders[Choosy::DSL::SuperCommandBuilder::HELP]
          raise Choosy::HelpCalled.new(Choosy::DSL::SuperCommandBuilder::SUPER)
        elsif @super_command.has_default?
          result.unparsed << @super_command.default_command.to_s
        else
          raise Choosy::SuperParseError.new("requires a command")
        end
      end

      result
    end

    def parse_command(args, terminals)
      command_name = args.shift
      command_builder = @super_command.command_builders[command_name.to_sym]
      if command_builder.nil?
        if command_name =~ /^-/
          raise Choosy::SuperParseError.new("unrecognized option: '#{command_name}'")
        else
          raise Choosy::SuperParseError.new("unrecognized command: '#{command_name}'")
        end
      end

      command = command_builder.entity
      parser = Parser.new(command, false, terminals)
      command_result = Choosy::ParseResult.new(command, true)
      parser.parse!(args, command_result)

      command_result
    end
  end
end

