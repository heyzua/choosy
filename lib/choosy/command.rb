require 'choosy/errors'
require 'choosy/dsl/command_builder'

module Choosy
  class Command
    attr_reader :name
    
    def initialize(name)
      @name = name
      @builder = CommandBuilder.new(self)
      yield builder if block_given?
    end

    

    def method_missing?(sym, *args, &block)
      # TODO: check the associated builder for adding actions.
    end
  end
end
