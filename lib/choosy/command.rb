require 'choosy/errors'
require 'choosy/dsl/command_builder'
require 'choosy/parser'
require 'choosy/verifier'

module Choosy
  class Command
    attr_accessor :name, :executor, :summary, :description
    attr_accessor :argument_validation, :printer
    attr_reader :listing, :builders, :builder
    
    def initialize(name)
      @name = name
      @listing = []
      @builders = {}

      @builder = Choosy::DSL::CommandBuilder.new(self)
      yield @builder if block_given?
      @builder.finalize!
    end

    def alter(&block)
      yield @builder if block_given?
      @builder.finalize!
    end

    def parse!(args, propagate=false)
      if propagate
        return parse(args)
      else
        begin
          return parse(args)
        rescue Choosy::ValidationError, Choosy::ConversionError, Choosy::ParseError => e
          STDERR.puts "#{name}: #{e.message}"
          exit 1
        rescue Choosy::HelpCalled => e
          printer.print!(self)
          exit 0
        rescue Choosy::VersionCalled => e
          STDOUT.puts e.message
          exit 0
        end
      end
    end

    def execute!(args)
      raise Choosy::ConfigurationError.new("No executor given for: #{name}") unless executor
      result = parse!(args)
      executor.call(result.options, result.args)
    end

    def options
      @builders.values.map {|b| b.option}
    end

    private
    def parse(args)
      opts = options
      parser = Parser.new(opts)
      result = parser.parse!(args)
      # TODO: Doesn't order dependencies yet
      verifier = Verifier.new(self)
      verifier.verify!(result)
      result
    end
  end
end
