module Choosy::DSL
  class OptionBuilder < ArgumentBuilder
    HELP = :__help__
    VERSION = :__version__

    def initialize(name, &block)
      super()
      @name = name
      if block_given?
        self.instance_eval(&block)
      end
    end

    def entity
      @entity ||= Choosy::Option.new(@name)
    end

    def short(flag, meta=nil)
      entity.short_flag = flag
      metaname(meta)
    end

    def long(flag, meta=nil)
      entity.long_flag = flag
      metaname(meta)
    end

    def flags(shorter, longer=nil, meta=nil)
      short(shorter)
      long(longer) if longer
      metaname(meta) if meta
    end

    def desc(description)
      entity.description = description
    end

    def default(value)
      entity.default_value = value
    end

    def depends_on(*args)
      if args.length == 1 && args[0].is_a?(Array)
        entity.dependent_options = args[0]
      else
        entity.dependent_options = args
      end
    end

    def negate(prefix=nil)
      prefix ||= 'no'
      entity.negation = prefix
    end

    def die(msg)
      flag_fmt = if entity.short_flag && entity.long_flag
                   "#{entity.short_flag}/#{entity.long_flag}"
                 end
      flag_fmt ||= entity.short_flag || entity.long_flag
      flag_meta = if entity.metaname
                     " #{entity.metaname}"
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
  end
end
