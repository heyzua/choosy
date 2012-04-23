module Choosy::DSL
  class ArgumentBuilder
    include BaseBuilder

    def initialize
      @count_called = false
    end

    def entity
      @entity ||= Choosy::Argument.new
    end

    def required(value=nil)
      entity.required = if value.nil? || value == true
                          true
                        else 
                          false
                        end
    end

    def only(*args)
      if args.nil? || args.empty?
        raise Choosy::ConfigurationError.new("'only' requires at least one argument")
      end

      entity.allowable_values = args
      if args.length > 0 && entity.cast_to.nil?
        if args[0].is_a?(Symbol) 
          cast :symbol
        else
          cast :string
        end
      end
    end

    def metaname(meta)
      return if meta.nil?
      entity.metaname = meta
      return if @count_called
      
      if meta =~ /\+$/
        entity.multiple!
      else
        entity.single!
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
        
        entity.arity = (lower_bound .. upper_bound)
      elsif restriction.is_a?(Range)
        entity.arity = restriction
      elsif restriction == :zero || restriction == :none
        entity.boolean!
      elsif restriction == :once
        entity.single!
      else
        check_count(restriction)
        entity.arity = (restriction .. restriction)
      end
    end

    def cast(ty)
      entity.cast_to = Choosy::Converter.for(ty)
      if entity.cast_to.nil?
        raise Choosy::ConfigurationError.new("Unknown conversion cast: #{ty}")
      end
    end
    
    def validate(&block)
      entity.validation_step = block
    end
    
    def die(msg)
      raise Choosy::ValidationError.new("argument error: #{msg}")
    end

    protected
    def check_count(count)
      if !count.is_a?(Integer)
        raise Choosy::ConfigurationError.new("Expected a number to count, got '#{count}'")
      end
    end
  end
end
