require 'choosy/verifier'

module Choosy
  class Verifier
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def validate!(result)
    end

    def populate_default!(option, result)
      if !result.options.has_key?(option.name) # Not already set
        if !option.default_value.nil? # Has default?
          result[option.name] = option.default_value
        elsif option.cast_to == :boolean
          result[option.name] = false
        elsif option.arity.max > 1
          result[option.name] = []
        else
          result[option.name] = nil
        end
      end
    end

    def validate_option!(option, result)
      
    end
  end
end
