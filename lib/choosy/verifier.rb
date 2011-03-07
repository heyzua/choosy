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
      if result.command.is_a?(Choosy::Command)
        prefix = if result.subresult?
                   "#{result.command.name}: "
                 else
                   ""
                 end

        if result.command.arguments
          arguments = result.command.arguments

          if result.args.length < arguments.arity.min
            raise Choosy::ValidationError.new("#{prefix}too few arguments (minimum is #{arguments.arity.min})")
          elsif result.args.length > arguments.arity.max
            raise Choosy::ValidationError.new("#{prefix}too many arguments (max is #{arguments.arity.max}): '#{result.args[arguments.arity.max]}'")
          end 

          if arguments.validation_step
            arguments.validation_step.call(result.args, result.options)
          end
        else
          if result.args.length > 0
            raise Choosy::ValidationError.new("#{prefix}no arguments allowed: #{result.args.join(' ')}")
          end
        end
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

    def restricted?(option, result)
      return unless option.restricted?
      
      value = result[option.name]
      if option.arity.max > 1
        value.each do |val|
          check(option.allowable_values, val)
        end
      else
        check(option.allowable_values, value)
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

    def check(allowable, value)
      if !allowable.include?(value)
        raise ValidationError.new("unrecognized value (only #{allowable.map{|s| "'#{s}'"}.join(', ')} allowed): '#{value}'")
      end
    end
  end
end
