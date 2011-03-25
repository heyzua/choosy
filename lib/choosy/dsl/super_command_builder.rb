require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/command'

module Choosy::DSL
  class SuperCommandBuilder < BaseCommandBuilder
    HELP = :help
    SUPER = :__SUPER_COMMAND__

    def command(cmd, &block)
      subcommand = if cmd.is_a?(Choosy::Command)
                     cmd.parent = entity
                     cmd
                   else
                     Choosy::Command.new(cmd, entity)
                   end

      evaluate_command_builder!(subcommand.builder, &block)
    end

    def parsimonious
      @entity.parsimonious = true
    end

    def metaname(meta)
      @entity.metaname = meta
    end

    def default(cmd)
      @entity.default_command = cmd
    end

    def help(msg=nil, &block)
      msg ||= "Show the info for a command, or this message"
      help_command = Choosy::Command.new HELP do |help|
        help.summary msg

        help.arguments do
          count 0..1
          validate do |args, options|
            if args.nil?
              raise Choosy::HelpCalled.new(SUPER)
            elsif args.is_a?(Array)
              if args.length == 0
                raise Choosy::HelpCalled.new(SUPER)
              else
                raise Choosy::HelpCalled.new(args[0].to_sym)
              end
            else
              raise Choosy::HelpCalled.new(args.to_sym)
            end
          end
        end
      end
      evaluate_command_builder!(help_command.builder, &block)
    end

    protected
    def evaluate_command_builder!(builder, &block)
      builder.evaluate!(&block)
      @entity.listing << builder.entity
      @entity.command_builders[builder.entity.name] = builder
      builder.entity
    end
  end
end
