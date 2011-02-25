require 'choosy/errors'
require 'choosy/dsl/option_builder'

module Choosy::DSL
  class CommandBuilder
    HELP = :__help__
    VERSION = :__version__

    attr_reader :command

    def initialize(command)
      @command = command
    end

    def executor(exec=nil, &block)
      if exec.nil? 
        if block_given?
          @command.executor = block
        else
          raise Choosy::ConfigurationError.new("The executor was nil")
        end
      else
        if !exec.respond_to?(:execute!)
          raise Choosy::ConfigurationError.new("Execution class doesn't implement 'execute!'")
        end
        @command.executor = exec
      end
    end

    def summary(msg)
      @command.summary = msg
    end
    
    def desc(msg)
      @command.description = msg
    end

    def separator(msg=nil)
      @command.listing << (msg.nil? ? "" : msg)
    end

    def option(arg)
      raise Choosy::ConfigurationError.new("The option name was nil") if arg.nil?
      
      builder = nil

      if arg.is_a?(Hash)
        raise Choosy::ConfigurationError.new("Malformed option hash") if arg.count != 1
        name = arg.keys[0]
        builder = OptionBuilder.new(name)

        to_process = arg[name]
        if to_process.is_a?(Array)
          builder.dependencies to_process
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
      finalize_builder builder
    end

    # Option types
    
    def boolean(sym, desc, config=nil, &block)
      simple_option(sym, desc, nil, config, &block)
    end

    def single(sym, desc, config=nil, &block)
      simple_option(sym, desc, sym.to_s.upcase, config, &block)
    end

    def multiple(sym, desc, config=nil, &block)
      simple_option(sym, desc, "#{sym}+".upcase, config, &block)
    end

    def help(msg=nil)
      h = OptionBuilder.new(HELP)
      h.short '-h'
      h.long '--help'
      h.desc (msg || "Show this help message")

      h.validate do
        raise Choosy::HelpCalled.new
      end 

      finalize_builder h
    end

    def version(msg)
      v = OptionBuilder.new(VERSION)
      v.long '--version'
      v.desc "The version number"

      v.validate do
        raise Choosy::VersionCalled.new(msg)
      end

      yield v if block_given?
      finalize_builder v
    end

    def arguments(&block)
      raise Choosy::ConfigurationError.new("No block to arguments call") if !block_given?

      command.argument_validation = block
    end

    private
    def finalize_builder(builder)
      builder.finalize!
      command.builders[builder.option.name] = builder
      command.listing << builder.option

      builder.option
    end

    def simple_option(sym, desc, param, config, &block)
      name = sym.to_s
      builder = OptionBuilder.new sym
      builder.desc desc
      builder.short "-#{name[0]}"
      builder.long "--#{name.downcase.gsub(/_/, '-')}"
      builder.param param
      builder.from_hash config if config

      yield builder if block_given?
      finalize_builder builder
    end
  end
end
