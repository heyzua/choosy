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

    def parsimonious=(value)
      @parsimonious = value
    end

    def parsimonious?
      @parsimonous ||= false
    end

    protected
    def create_builder
      Choosy::DSL::SuperCommandBuilder.new(self)
    end

    def parse(args)
      global_result = parse_globals(args)
  
      terminals = parsimonious? ? command_names : []
      unparsed = global_result.unparsed
      commands = []

      while unparsed.length > 0
        command, command_result = parse_command(unparsed, terminals)
        command_result.options.merge!(global_results.options)
        commands << [command, command_result]
        
        unparsed = command_result.unparsed
      end

      commands
    end

    def handle_help(hc)
      command_name = hc.message

      if command_name == @name
        printer.print!(self)
      end
      
      builder = command_builders[command_name]
      if builder
        printer.print!(builder.command)
      else
        $stderr << "#{@name}: #{format_help(command_name)}\n"
        exit 1
      end
    end

    def parse_globals(args)
      # first, scan out all of the global options
      global_parser = Parser.new(options, true) 
      global_result = global_parser.parse!(args)
      global_verifier = Verifier.new(self)
      global_verifier.verify!(global_result)

      # if we found a global action, we should have hit it by now...
      if global_result.unparsed.length == 0
        if command_builders[:help]
          raise Choosy::HelpCalled.new(@name)
        else
          raise Choosy::CommandLineError.new("Requires a command")
        end
      end

      global_result
    end

    def parse_command(args, terminals)
      command_name = args[0].to_sym
      command = command_builders[command_name]
      if command.nil?
        raise Choosy::CommandLineError.new(format_help(command))
      end

      command_parser = Parser.new(command.options, false, terminals)
      command_result = command_parser.parse!(args[1,])
      command_verifier = Verifier.new(command)
      command_verifier.verify!(command_result)

      [command, command_result]
    end

    def command_names
      command_builders.values.map {|b| b.name.to_s }
    end

    def format_help(command)
      help = if command_builders[:help]
               "See '#{@name} help'."
             else
               ""
             end
      "'#{command}' is not a standard command. #{help}"
    end
  end
end
