require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/dsl/option_builder'
require 'choosy/printing/help_printer'

module Choosy::DSL
  class CommandBuilder < BaseCommandBuilder
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

    def help(msg=nil)
      h = OptionBuilder.new(OptionBuilder::HELP)
      h.short '-h'
      h.long '--help'
      msg ||= "Show this help message"
      h.desc msg

      h.validate do
        raise Choosy::HelpCalled.new
      end 

      finalize_option_builder h
    end

    def arguments(&block)
      raise Choosy::ConfigurationError.new("No block to arguments call") if !block_given?

      command.argument_validation = block
    end
    
    def finalize!
      if @command.printer.nil?
        printer :standard
      end
    end

    protected
    def create_printer
      Choosy::Printing::HelpPrinter.new
    end
  end
end
