require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/dsl/option_builder'
require 'choosy/dsl/argument_builder'
require 'choosy/printing/help_printer'

module Choosy::DSL
  class CommandBuilder < BaseCommandBuilder
    def executor(exec=nil, &block)
      if exec.nil? 
        if block_given?
          @entity.executor = block
        else
          raise Choosy::ConfigurationError.new("The executor was nil")
        end
      else
        if !exec.respond_to?(:execute!)
          raise Choosy::ConfigurationError.new("Execution class doesn't implement 'execute!'")
        end
        @entity.executor = exec
      end
    end

    def arguments(&block)
      builder = ArgumentBuilder.new
      # Set multiple by default
      builder.entity.multiple!
      builder.evaluate!(&block)
      
      if builder.entity.metaname.nil?
        builder.metaname 'ARGS+'
      end

      entity.arguments = builder.entity
    end
  end
end
