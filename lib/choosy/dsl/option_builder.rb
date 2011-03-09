require 'choosy/option'
require 'choosy/errors'
require 'choosy/converter'
require 'choosy/dsl/argument_builder'

module Choosy::DSL
  class OptionBuilder < ArgumentBuilder
    HELP = :__help__
    VERSION = :__version__

    def initialize(name)
      super()
      @name = name
    end

    def option
      @argument ||= Choosy::Option.new(@name)
    end

    alias :argument :option

    def short(flag, meta=nil)
      option.short_flag = flag
      metaname(meta)
    end

    def long(flag, meta=nil)
      option.long_flag = flag
      metaname(meta)
    end

    def flags(shorter, longer=nil, meta=nil)
      short(shorter)
      long(longer) if longer
      metaname(meta) if meta
    end

    def desc(description)
      option.description = description
    end

    def default(value)
      option.default_value = value
    end

    def depends_on(*args)
      if args.length == 1 && args[0].is_a?(Array)
        option.dependent_options = args[0]
      else
        option.dependent_options = args
      end
    end

    def only(*args)
      option.allowable_values = args
    end

    def negate(prefix=nil)
      prefix ||= 'no'
      option.negation = prefix
    end

    def die(msg)
      flag_fmt = if option.short_flag && option.long_flag
                   "#{option.short_flag}/#{option.long_flag}"
                 end
      flag_fmt ||= option.short_flag || option.long_flag
      flag_meta = if option.metaname
                     " #{option.metaname}"
                   end
      raise Choosy::ValidationError.new("#{flag_fmt}#{flag_meta}: #{msg}")
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
      super

      if option.cast_to.nil?
        if option.boolean?
          option.cast_to = :boolean
        else
          option.cast_to = :string
        end
      end

      if option.boolean?
        if option.restricted?
          raise Choosy::ConfigurationError.new("Options cannot be both boolean and restricted to certain arguments: #{option.name}")
        elsif option.negated? && option.long_flag.nil?
          raise Choosy::ConfigurationError.new("The long flag is required for negation: #{option.name}")
        end
        option.default_value ||= false
      else
        if option.negated?
          raise Choosy::ConfigurationError.new("Unable to negate a non-boolean option: #{option.name}")
        end
      end
    end
  end
end
