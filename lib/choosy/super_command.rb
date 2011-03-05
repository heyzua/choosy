require 'choosy/errors'
require 'choosy/parser'
require 'choosy/base_command'
require 'choosy/super_parser'
require 'choosy/dsl/super_command_builder'

module Choosy
  class SuperCommand < BaseCommand
    attr_reader :command_builders

    def command_builders
      @command_builders ||= {}
    end

    def commands
      @command_builders.values.map {|b| b.command }
    end

    def parsimonious=(value)
      @parsimonious = value
    end

    def parsimonious?
      @parsimonous ||= false
    end

    def execute!(args)
      super_result = parse!(args)
      super_result.subresults.each do |result|
        cmd = result.command
        if cmd.executor.nil?
          raise Choosy::ConfigurationError.new("No executor given for: #{cmd.name}")
        end
      end

      super_result.subresults.each do |result|
        cmd = result.command
        cmd.executor.call(result.options, result.args)
      end
    end

    protected
    def create_builder
      Choosy::DSL::SuperCommandBuilder.new(self)
    end

    def parse(args)
      parser = SuperParser.new(self)
      parser.parse!(args)
    end

    def handle_help(hc)
      command_name = hc.message

      if command_name == :SUPER_COMMAND
        puts printer.print!(self)
      else
        builder = command_builders[command_name]
        if builder
          puts printer.print!(builder.command)
        else
          $stdout << "#{@name}: #{format_help(command_name)}\n"
          exit 1
        end
      end
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
