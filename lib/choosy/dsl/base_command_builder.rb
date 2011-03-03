require 'choosy/errors'
require 'choosy/dsl/option_builder'
require 'choosy/printing/erb_printer'
require 'choosy/printing/formatting_element'

module Choosy::DSL
  class BaseCommandBuilder
    attr_reader :command

    def initialize(command)
      @command = command
    end

    # Generic setup

    def summary(msg)
      @command.summary = msg
    end

    def printer(kind, options=nil)
      return if kind.nil?

      p = nil
      if kind == :standard
        p = Choosy::Printing::HelpPrinter.new
      elsif kind == :erb
        p = Choosy::Printing::ERBPrinter.new
        if options.nil? || options[:template].nil?
          raise Choosy::ConfigurationError.new("no template file given to ERBPrinter")
        elsif !File.exist?(options[:template])
          raise Choosy::ConfigurationError.new("the template file doesn't exist: #{options[:template]}")
        end
        p.template = options[:template]
      elsif kind.respond_to?(:print!)
        p = kind
      else
        raise Choosy::ConfigurationError.new("Unknown printing method for help: #{kind}")
      end

      if p.respond_to?(:color) && options && options.has_key?(:color)
        p.color.disable! if !options[:color]
      end
      if p.respond_to?(:columns=) && options && options.has_key?(:max_width)
        p.columns = options[:max_width]
      end
      if p.respond_to?(:header_attrs=) && options && options.has_key?(:headers)
        p.header_attrs = options[:headers]
      end

      @command.printer = p
    end

    # Formatting

    def header(msg, *attrs)
      @command.listing << Choosy::Printing::FormattingElement.new(:header, msg, attrs)
    end

    def para(msg=nil, *attrs)
      @command.listing << Choosy::Printing::FormattingElement.new(:para, msg, attrs)
    end

    # Options

    def option(arg)
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

      yield builder if block_given?
      finalize_option_builder builder
    end

    def self.create_conversions
      Choosy::Converter::CONVERSIONS.keys.each do |method|
        next if method == :boolean || method == :bool

        define_method method do |sym, desc, config=nil, &block|
          simple_option(sym, desc, true, :one, method, config, &block)
        end

        plural = "#{method}s".to_sym
        define_method plural do |sym, desc, config=nil, &block|
          simple_option(sym, desc, true, :many, method, config, &block)
        end

        underscore = "#{method}_"
        define_method underscore do |sym, desc, config=nil, &block|
          simple_option(sym, desc, false, :one, method, config, &block)
        end

        plural_underscore = "#{plural}_".to_sym
        define_method plural_underscore do |sym, desc, config=nil, &block|
          simple_option(sym, desc, false, :many, method, config, &block)
        end
      end
    end

    create_conversions
    alias :single :string
    alias :single_ :string_

    alias :multiple :strings
    alias :multiple_ :strings_

    def boolean(sym, desc, config=nil, &block)
      simple_option(sym, desc, true, :zero, :boolean, config, &block)
    end
    def boolean_(sym, desc, config=nil, &block)
      simple_option(sym, desc, false, :zero, :boolean, config, &block)
    end
    alias :bool :boolean
    alias :bool_ :boolean_

    # Additional helpers

    def version(msg)
      v = OptionBuilder.new(OptionBuilder::VERSION)
      v.long '--version'
      v.desc "The version number"

      v.validate do
        raise Choosy::VersionCalled.new(msg)
      end

      yield v if block_given?
      finalize_option_builder v
    end

    def finalize!
      if @command.printer.nil?
        printer :standard
      end
    end

    protected
    def finalize_option_builder(option_builder)
      option_builder.finalize!
      @command.option_builders[option_builder.option.name] = option_builder
      @command.listing << option_builder.option

      option_builder.option
    end

    private
    def simple_option(sym, desc, allow_short, meta, cast, config, &block)
      name = sym.to_s
      builder = OptionBuilder.new sym
      builder.desc desc
      builder.short "-#{name[0]}" if allow_short
      builder.long "--#{name.downcase.gsub(/_/, '-')}"
      builder.metaname format_meta(name, meta)
      builder.cast cast
      builder.from_hash config if config

      yield builder if block_given?
      finalize_option_builder builder
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
