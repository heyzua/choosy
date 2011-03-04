require 'choosy/errors'

module Choosy
  class BaseCommand
    attr_accessor :name, :summary, :printer
    attr_reader :builder, :listing, :option_builders
    
    def initialize(name)
      @name = name
      @listing = []
      @option_builders = {}

      @builder = create_builder
      yield @builder if block_given?
      @builder.finalize!
    end

    def alter(&block)
      yield @builder if block_given?
      @builder.finalize!
    end

    def options
      @option_builders.values.map {|b| b.option}
    end

    def parse!(args, propagate=false)
      if propagate
        return parse(args)
      else
        begin
          return parse(args)
        rescue Choosy::ValidationError, Choosy::ConversionError, Choosy::ParseError, Choosy::SuperParseError => e
          $stderr << "#{@name}: #{e.message}\n"
          exit 1
        rescue Choosy::HelpCalled => e
          handle_help(e)
          exit 0
        rescue Choosy::VersionCalled => e
          $stdout <<  "#{e.message}\n"
          exit 0
        end
      end
    end

    protected
    def create_builder
      # Override in subclasses
    end

    def parse(args)
      # Override in subclasses
    end

    def handle_help(hc)
      # Override in subclasses
    end
  end
end
