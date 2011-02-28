require 'choosy/option'
require 'choosy/errors'
require 'choosy/converter'

module Choosy::DSL
  class OptionBuilder
    ZERO_ARITY     = (0 .. 0)
    ONE_ARITY      = (1 .. 1)
    MANY_ARITY     = (1 .. 1000)
    
    attr_reader :option
    
    def initialize(name)
      @option = Choosy::Option.new(name)
      @count_called = false
    end

    def short(flag, param=nil)
      option.short_flag = flag
      param(param)
    end

    def long(flag, param=nil)
      option.long_flag = flag
      param(param)
    end

    def flags(shorter, longer=nil, parameter=nil)
      short(shorter)
      long(longer) if longer
      param(parameter) if parameter
    end

    def desc(description)
      option.description = description
    end

    def default(value)
      option.default_value = value
    end

    def required(value=nil)
      option.required = if value.nil? || value == true
                          true
                        else 
                          false
                        end
    end

    def param(param)
      return if param.nil?
      option.flag_parameter = param
      return if @count_called
      
      if param =~ /\+$/
        option.arity = MANY_ARITY 
      else
        option.arity = ONE_ARITY
      end
    end

    def count(restriction)
      @count_called = true
      if restriction.is_a?(Hash)
        lower_bound = restriction[:at_least] || restriction[:exactly] || 1
        upper_bound = restriction[:at_most] || restriction[:exactly] || 1000

        check_count(lower_bound)
        check_count(upper_bound)
        if lower_bound > upper_bound
          raise Choosy::ConfigurationError.new("The upper bound (#{upper_bound}) is less than the lower bound (#{lower_bound}).")
        end
        
        option.arity = (lower_bound .. upper_bound)
      elsif restriction == :zero || restriction == :none
        option.arity = ZERO_ARITY
      elsif restriction == :once
        option.arity = ONE_ARITY
      else
        check_count(restriction)
        option.arity = (restriction .. restriction)
      end
    end

    def cast(ty)
      option.cast_to = Choosy::Converter.for(ty)
      if option.cast_to.nil?
        raise Choosy::ConfigurationError.new("Unknown conversion cast: #{ty}")
      end
    end
    
    def validate(&block)
      option.validation_step = block
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

    def dependencies(*args)
      if args.count == 1 && args[0].is_a?(Array)
        option.dependent_options = args[0]
      else
        option.dependent_options = args
      end
    end

    def from_hash(hash)
      raise Choosy::ConfigurationError.new("Only hash arguments allowed") if !hash.is_a?(Hash)

      hash.each do |k, v|
        if respond_to?(k)
          if v.is_a?(Array)
            self.send(k, *v)
          else
            self.send(k, v)
          end
        else
          raise Choosy::ConfigurationError.new("Not a recognized option: #{k}")
        end
      end
    end
    
    def finalize!
      if option.arity.nil?
        option.arity = ZERO_ARITY
      end

      if option.cast_to.nil?
        if option.arity == ZERO_ARITY
          option.cast_to = :boolean
        else
          option.cast_to = :string
        end
      end
    end

    private
    def check_count(count)
      if !count.is_a?(Integer)
        raise Choosy::ConfigurationError.new("Expected a number to count, got '#{count}'")
      end
    end
  end
end
