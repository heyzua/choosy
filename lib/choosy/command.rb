require 'choosy/errors'
require 'choosy/dsl/command_builder'
require 'choosy/parser'

module Choosy
  class Command
    attr_accessor :name, :executor, :summary, :description
    attr_accessor :argument_validation
    attr_reader :listing, :builders, :builder
    
    def initialize(name)
      @name = name
      @listing = []
      @builders = {}

      @builder = Choosy::DSL::CommandBuilder.new(self)
      yield @builder if block_given?
    end

    def alter(&block)
      yield @builder if block_given?
    end

    def parse!(args)
      opts = options
      parser = Parser.new(opts)
      result = parser.parse!(args)
      # TODO: Doesn't order dependencies yet
      verifier = Verifier.new(self)
      verifier.verify!(result)
      result
    end

    def execute!(args, propagate=false)
      if propagate
        execute(args)
      else
        begin
          execute(args)
        # TODO: Refine this
        rescue Choosy::Error => e
          STDERR.puts "#{name}: #{e.message}"
          exit 1
        end
      end
    end

    def options
      @builders.values.map {|b| b.option}
    end

    private
    def execute(args)
      # TODO
    end
  end
end
