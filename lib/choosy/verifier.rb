require 'choosy/errors'
require 'choosy/dsl/option_builder'

module Choosy
  class Verifier
    def verify!(result)
      result.command.options.each do |option|
        required?(option, result)
        populate!(option, result)
        convert!(option, result)
        validate!(option, result)
      end

      verify_arguments!(result)
    end

    def verify_special!(result)
      result.command.options.each do |option|
        if special?(option)
          validate!(option, result) 
        end
      end
    end

    def verify_arguments!(result)
      if result.command.respond_to?(:argument_validation) && result.command.argument_validation
        result.command.argument_validation.call(result.args)
      end
    end

    def required?(option, result)
      if option.required? && result[option.name].nil?
        raise ValidationError.new("required option missing: '#{option.long_flag}'")
      end
    end
    
    def populate!(option, result)
      return if special?(option)

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
        option.validation_step.call(value, result.options)
      end
    end

    private
    def exists?(value)
      value && value != []
    end

    def special?(option)
      option.name == Choosy::DSL::OptionBuilder::HELP || option.name == Choosy::DSL::OptionBuilder::VERSION
    end
  end
end
