module Choosy
  class Argument
    ZERO_ARITY     = (0 .. 0)
    ONE_ARITY      = (1 .. 1)
    MANY_ARITY     = (1 .. 1000)

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
      @arity == ZERO_ARITY
    end

    def single?
      @arity == ONE_ARITY
    end

    def multiple?
      @arity == MANY_ARITY
    end

    def boolean!
      @arity = ZERO_ARITY
    end

    def single!
      @arity = ONE_ARITY
    end

    def multiple!
      @arity = MANY_ARITY
    end

    def finalize!
      @arity ||= ZERO_ARITY
      @cast_to ||= :string
    end
  end
end
