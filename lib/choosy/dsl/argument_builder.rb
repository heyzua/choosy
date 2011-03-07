require 'choosy/errors'
require 'choosy/argument'
require 'choosy/converter'

module Choosy::DSL
  class ArgumentBuilder
    def initialize
      @count_called = false
    end

    def argument
      @argument ||= Choosy::Argument.new
    end
    
    def required(value=nil)
      argument.required = if value.nil? || value == true
                          true
                        else 
                          false
                        end
    end

    def metaname(meta)
      return if meta.nil?
      argument.metaname = meta
      return if @count_called
      
      if meta =~ /\+$/
        argument.multiple!
      else
        argument.single!
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
        
        argument.arity = (lower_bound .. upper_bound)
      elsif restriction.is_a?(Range)
        argument.arity = restriction
      elsif restriction == :zero || restriction == :none
        argument.boolean!
      elsif restriction == :once
        argument.single!
      else
        check_count(restriction)
        argument.arity = (restriction .. restriction)
      end
    end

    def cast(ty)
      argument.cast_to = Choosy::Converter.for(ty)
      if argument.cast_to.nil?
        raise Choosy::ConfigurationError.new("Unknown conversion cast: #{ty}")
      end
    end
    
    def validate(&block)
      argument.validation_step = block
    end
    
    def die(msg)
      raise Choosy::ValidationError.new("argument error: #{msg}")
    end

    def finalize!
      if argument.arity.nil?
        argument.boolean!
      end
    end

    protected
    def check_count(count)
      if !count.is_a?(Integer)
        raise Choosy::ConfigurationError.new("Expected a number to count, got '#{count}'")
      end
    end
  end
end
