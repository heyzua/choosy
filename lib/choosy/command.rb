require 'choosy/errors'
require 'choosy/dsl/command_builder'

module Choosy
  class Command
    attr_accessor :name, :executor, :summary, :description
    attr_accessor :argument_validation
    attr_reader :listing, :builders
    
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


  end
end
