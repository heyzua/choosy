require 'choosy/errors'

module Choosy
  class Argument
    attr_accessor :metaname, :validation_step, :arity, :cast_to

    def initialize
      @required = false
    end

    def required=(val)
      @required = val
    end

    def required?
      @required
    end
  end
end
