require 'choosy/errors'
require 'choosy/dsl/argument_builder'

module Choosy
  class Argument
    attr_accessor :metaname, :validation_step, :arity, :cast_to, :allowable_values

    def initialize
      @required = false
    end

    def required=(val)
      @required = val
    end

    def required?
      @required
    end

    def restricted?
      !allowable_values.nil? && allowable_values.length > 0
    end

    def boolean?
      arity == Choosy::DSL::ArgumentBuilder::ZERO_ARITY
    end

    def single?
      arity == Choosy::DSL::ArgumentBuilder::ONE_ARITY
    end
  end
end
