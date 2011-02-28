require 'choosy/errors'

module Choosy
  class BaseCommand
    attr_accessor :name, :summary, :description, :printer
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

    protected
    def create_builder
      # Override in subclasses
    end
  end
end
