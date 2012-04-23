module Choosy
  class Option < Argument
    attr_accessor :name, :description
    attr_accessor :short_flag, :long_flag
    attr_accessor :default_value
    attr_accessor :dependent_options
    attr_accessor :negation

    def initialize(name)
      super()
      @name = name
    end

    def negated?
      !negation.nil?
    end

    def negated
      @negated ||= long_flag.gsub(/^--/, "--#{negation}-")
    end

    def finalize!
      @arity ||= ZERO_ARITY
      @cast_to ||= boolean? ? :boolean : :string

      if boolean?
        if restricted?
          raise Choosy::ConfigurationError.new("Options cannot be both boolean and restricted to certain arguments: #{@name}")
        elsif negated? && @long_flag.nil?
          raise Choosy::ConfigurationError.new("The long flag is required for negation: #{@name}")
        end
        @default_value ||= false
      else
        if negated?
          raise Choosy::ConfigurationError.new("Unable to negate a non-boolean option: #{@name}")
        end
      end
    end
  end
end
