require 'choosy/errors'
require 'choosy/parser'
require 'choosy/parse_result'

module Choosy
  class SuperParser
    attr_reader :terminals

    def initialize(super_command, parsimonious=nil)
      @super_command = super_command
      @parsimonious = parsimonious || false
      generate_terminals
    end

    def parsimonious?
      @parsimonious
    end

    def parse!(args)
      result = parse_globals(args)
      unparsed = result.unparsed

      while unparsed.length > 0
        command_result = parse_command(unparsed, terminals)
        command_result.options.merge!(result.options)
        result.subresults << command_result
        
        unparsed = command_result.unparsed
      end

      result
    end

    private
    def generate_terminals
      @terminals = []
      if parsimonious?
        @super_command.commands.each do |c|
          @terminals << c.name.to_s
        end
      end
    end

    def parse_globals(args)
      result = SuperParseResult.new(@super_command)
      parser = Parser.new(@super_command, true)
      parser.parse!(args, result)
      result.verify!

      # if we found a global action, we should have hit it by now...
      if result.unparsed.length == 0
        if @super_command.command_builders[:help]
          raise Choosy::HelpCalled.new(@super_command.name)
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

      command = command_builder.command
      parser = Parser.new(command, false, terminals)
      command_result = parser.parse!(args)

      command_result.verify!
    end
  end
end

