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

    def printer(kind, options={})
      @command.printer =  if kind == :standard
                            Choosy::Printing::HelpPrinter.new(options)
                          elsif kind == :erb
                            Choosy::Printing::ERBPrinter.new(options)
                          elsif kind.respond_to?(:print!)
                            kind
                          else
                            raise Choosy::ConfigurationError.new("Unknown printing method for help: #{kind}")
                          end
    end

    # Formatting

    def header(msg, *styles)
      @command.listing << Choosy::Printing::FormattingElement.new(:header, msg, styles)
    end

    def para(msg=nil, *styles)
      @command.listing << Choosy::Printing::FormattingElement.new(:para, msg, styles)
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

      if block_given?
        builder.instance_eval(&block)
      end
      finalize_option_builder builder
    end

    def self.create_conversions
      Choosy::Converter::CONVERSIONS.keys.each do |method|
        next if method == :boolean || method == :bool

        define_method method do |sym, desc, config=nil, &block|
          simple_option(sym, desc, true, :one, method, nil, config, &block)
        end

        plural = "#{method}s".to_sym
        define_method plural do |sym, desc, config=nil, &block|
          simple_option(sym, desc, true, :many, method, nil, config, &block)
        end

        underscore = "#{method}_"
        define_method underscore do |sym, desc, config=nil, &block|
          simple_option(sym, desc, false, :one, method, nil, config, &block)
        end

        plural_underscore = "#{plural}_".to_sym
        define_method plural_underscore do |sym, desc, config=nil, &block|
          simple_option(sym, desc, false, :many, method, nil, config, &block)
        end
      end
    end

    create_conversions
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

    def version(msg, &block)
      v = OptionBuilder.new(OptionBuilder::VERSION)
      v.long '--version'
      v.desc "The version number"

      v.validate do
        raise Choosy::VersionCalled.new(msg)
      end

      if block_given?
        v.instance_eval(&block)
      end
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
    def simple_option(sym, desc, allow_short, meta, cast, allowed, config, &block)
      name = sym.to_s
      builder = OptionBuilder.new sym
      builder.desc desc
      builder.short "-#{name[0]}" if allow_short
      builder.long "--#{name.downcase.gsub(/_/, '-')}"
      builder.metaname format_meta(name, meta)
      builder.cast cast
      if allowed
        builder.only *allowed
      end
      builder.from_hash config if config

      if block_given?
        builder.instance_eval(&block)
      end
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
