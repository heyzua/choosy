require 'choosy/errors'

module Choosy
  class Verifier
    attr_reader :options

    def initialize(command)
      @command = command
    end

    def verify!(result)
      @command.options.each do |option|
        required?(option, result)
        populate!(option, result)
        convert!(option, result)
        validate!(option, result)
      end

      if @command.argument_validation
        @command.argument_validation.call(result.args)
      end
    end

    def required?(option, result)
      if option.required? && result[option.name].nil?
        raise ValidationError.new("Required option '#{option.long_flag}' missing.")
      end
    end
    
    def populate!(option, result)
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

    def convert!(option, result)
      value = result[option.name]
      if exists? value
        result[option.name] = Converter.convert(option.cast_to, value)
      end
    end

    def validate!(option, result)
      value = result[option.name]
      if option.validation_step && exists?(value)
        option.validation_step.call(value)
      end
    end

    private
    def exists?(value)
      value && value != []
    end
  end
end
