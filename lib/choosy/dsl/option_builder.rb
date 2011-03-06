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
      if args.count == 1 && args[0].is_a?(Array)
        option.dependent_options = args[0]
      else
        option.dependent_options = args
      end
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
        if option.arity == ZERO_ARITY
          option.cast_to = :boolean
        else
          option.cast_to = :string
        end
      end
    end
  end
end
