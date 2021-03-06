module Choosy::DSL
  class BaseCommandBuilder
    include BaseBuilder

    attr_reader :entity

    def initialize(command)
      @entity = command
    end

    # Generic setup

    def summary(msg)
      @entity.summary = msg
    end

    def printer(kind, options={})
      @entity.printer =  if kind == :standard
                            Choosy::Printing::HelpPrinter.new(options)
                          elsif kind == :erb
                            Choosy::Printing::ERBPrinter.new(options)
                          elsif kind == :manpage
                            Choosy::Printing::ManpagePrinter.new(options)
                          elsif kind.respond_to?(:print!)
                            kind
                          else
                            raise Choosy::ConfigurationError.new("Unknown printing method for help: #{kind}")
                          end
    end

    # Formatting

    def heading(msg, *styles, &block)
      @entity.listing << Choosy::Printing::FormattingElement.new(:header, msg, styles)
      evaluate!(&block) if block_given?
    end

    alias :section :heading

    def para(msg=nil, *styles)
      @entity.listing << Choosy::Printing::FormattingElement.new(:para, msg, styles)
    end

    # Options

    def option(arg, &block)
      raise Choosy::ConfigurationError.new("The option name was nil") if arg.nil?
      
      builder = nil

      if arg.is_a?(Hash)
        raise Choosy::ConfigurationError.new("Malformed option hash") if arg.count != 1
        name = arg.keys[0]
        builder = OptionBuilder.new(name)

        to_process = arg[name]
        if to_process.is_a?(Array)
          builder.depends_on to_process
        elsif to_process.is_a?(Hash)
          builder.from_hash to_process
        else
          raise Choosy::ConfigurationError.new("Unable to process option hash")
        end
      else
        builder = OptionBuilder.new(arg)
        raise Choosy::ConfigurationError.new("No configuration block was given") if !block_given?
      end

      evaluate_option_builder!(builder, &block)
    end

    Choosy::Converter::CONVERSIONS.keys.each do |method|
      next if method == :boolean || method == :bool

      self.class_eval <<-EOF, __FILE__, __LINE__
        def #{method}(sym, desc, config=nil, &block)
          simple_option(sym, desc, true, :one, :#{method}, nil, config, &block)
        end

        def #{method}s(sym, desc, config=nil, &block)
          simple_option(sym, desc, true, :many, :#{method}, nil, config, &block)
        end

        def #{method}_(sym, desc, config=nil, &block)
          simple_option(sym, desc, false, :one, :#{method}, nil, config, &block)
        end

        def #{method}s_(sym, desc, config=nil, &block)
          simple_option(sym, desc, false, :many, :#{method}, nil, config, &block)
        end
      EOF
    end

    alias :single :string
    alias :single_ :string_

    alias :multiple :strings
    alias :multiple_ :strings_

    def boolean(sym, desc, config=nil, &block)
      simple_option(sym, desc, true, :zero, :boolean, nil, config, &block)
    end
    def boolean_(sym, desc, config=nil, &block)
      simple_option(sym, desc, false, :zero, :boolean, nil, config, &block)
    end
    alias :bool :boolean
    alias :bool_ :boolean_

    def enum(sym, allowed, desc, config=nil, &block)
      simple_option(sym, desc, true, :one, :symbol, allowed, config, &block)
    end

    def enum_(sym, allowed, desc, config=nil, &block)
      simple_option(sym, desc, false, :one, :symbol, allowed, config, &block)
    end

    # Additional helpers
    
    def help(msg=nil, &block)
      msg ||= "Show this help message"

      h = OptionBuilder.new(OptionBuilder::HELP) do
        short '-h'
        long '--help'
        desc msg
        validate do
          raise Choosy::HelpCalled.new(:help)
        end 
      end

      evaluate_option_builder!(h, &block)
    end

    def version(msg, &block)
      v = OptionBuilder.new(OptionBuilder::VERSION) do
        long '--version'
        desc "The version number"
        cast :boolean
        validate do
          raise Choosy::VersionCalled.new(msg)
        end
      end

      option_eigenclass = class << v.entity; self; end
      option_eigenclass.send :define_method, :version do
        msg
      end

      evaluate_option_builder!(v, &block)
    end

    def no_color(msg, &block)
      msg ||= "Disable the color"
      cmd = entity

      n = OptionBuilder.new(:no_color) do
        long "--no-color"
        desc msg
        cast :boolean
        validate do |args, options|
          if cmd.printer.respond_to?(:color)
            cmd.printer.color.disable!
          end
        end
      end

      evaluate_option_builder!(n, &block)
    end

    protected
    def evaluate_option_builder!(builder, &block)
      builder.evaluate!(&block)
      @entity.listing << builder.entity
      @entity.option_builders[builder.entity.name] = builder
      builder.entity
    end

    private
    def simple_option(sym, desc, allow_short, meta, cast, allowed, config, &block)
      name = sym.to_s
      builder = OptionBuilder.new sym
      builder.desc desc
      short = case name[0]
              when Fixnum
                name[0].chr
              else
                name[0]
              end

      builder.short "-#{short}" if allow_short
      builder.long "--#{name.downcase.gsub(/_/, '-')}"
      builder.metaname format_meta(name, meta)
      builder.cast cast
      if allowed
        builder.only(*allowed)
      end
      builder.from_hash config if config

      evaluate_option_builder!(builder, &block)
    end

    def format_meta(name, count)
      case count
      when :zero then nil
      when :one then name.upcase
      when :many then "#{name.upcase}+"
      end
    end
  end
end
