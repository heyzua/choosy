require 'choosy/errors'
require 'tsort'

module Choosy
  class OptionBuilderHash < Hash
    include TSort
    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
      deps = fetch(node).entity.dependent_options
      deps.each(&block) unless deps.nil?
    end
  end

  class BaseCommand
    attr_accessor :name, :summary, :printer
    attr_reader :builder, :listing, :option_builders
    
    def initialize(name, &block)
      @name = name
      @listing = []
      @option_builders = OptionBuilderHash.new
      @printer = nil

      @builder = create_builder
      @builder.evaluate!(&block)
    end

    def alter(&block)
      @builder.evaluate!(&block)
    end

    def options
      @option_builders.tsort.map {|key| @option_builders[key].entity }
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

    def execute!(args)
      begin
        execute(args)
      rescue Choosy::ClientExecutionError => e
        $stderr << "#{@name}: #{e.message}\n"
        exit 1
      end
    end

    def finalize!
      if @printer.nil?
        builder.printer :standard
      end
    end

    protected
    def create_builder
      # Override in subclasses
    end

    def parse(args)
      # Override in subclasses
    end

    def execute(args)
      # Override in subclasses
    end

    def handle_help(hc)
      # Override in subclasses
    end
  end
end
