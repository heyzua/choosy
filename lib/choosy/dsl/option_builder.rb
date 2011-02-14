require 'choosy/option'
require 'choosy/errors'

module Choosy::DSL
  class OptionBuilder
    ZERO_ARITY     = (0 .. 0)
    ONE_ARITY      = (1 .. 1)
    OPTIONAL_ARITY = (0 .. 1)
    MANY_ARITY     = (1 .. 1000)
    
    attr_reader :option
    
    def initialize(option)
      @option = option
    end

    def short(flag, param=nil)
      option.short_flag = flag
      check_param(param)
    end

    def long(flag, param=nil)
      option.long_flag = flag
      check_param(param)
    end

    def desc(description)
      option.description = description
    end

    def default(value)
      option.default_value = value
    end

    def required
      option.required = true
    end

    def count(restriction)
      if restriction.is_a?(Hash)
        lower_bound = restriction[:at_least] || restriction[:exactly] || 1
        upper_bound = restriction[:at_most] || restriction[:exactly] || 1000

        check_count(lower_bound)
        check_count(upper_bound)
        option.arity = (lower_bound .. upper_bound)
      elsif restriction == :zero
        option.arity = ZERO_ARITY
      elsif restriction == :once
        option.arity = ONE_ARITY
      else
        check_count(restriction)
        option.arity = (restriction .. restriction)
      end
    end

    def fail(msg)
      flag_fmt = if option.short_flag && option.long_flag
                   "#{option.short_flag}/#{option.long_flag}"
                 end
      flag_fmt ||= option.short_flag || option.long_flag
      flag_param = if option.flag_parameter
                     " #{option.flag_parameter}"
                   end
      raise Choosy::ValidationError.new("#{flag_fmt}#{flag_param}: #{msg}")
    end

=begin
    def validate(&block)
      option.validation_step = block
    end
=end
    
    private
    def check_param(param)
      return if param.nil?
      if param =~ /\?$/
        option.arity = OPTIONAL_ARITY
      elsif param =~ /\+$/
        option.arity = MANY_ARITY
      else
        option.arity = ONE_ARITY
      end
      option.flag_parameter = param
    end

    def check_count(count)
      if !count.is_a?(Integer)
        raise Choosy::ConfigurationError.new("Expected a number to count, got '#{count}'")
      end
    end
  end
end
