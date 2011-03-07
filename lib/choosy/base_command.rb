require 'choosy/errors'
require 'tsort'

module Choosy
  class OptionBuilderHash < Hash
    include TSort
    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
      deps = fetch(node).option.dependent_options
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

      @builder = create_builder
      if block_given?
        @builder.instance_eval(&block)
      end
      @builder.finalize!
    end

    def alter(&block)
      if block_given?
        @builder.instance_eval(&block)
      end
      @builder.finalize!
    end

    def options
      @option_builders.tsort.map {|key| @option_builders[key].option }
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
