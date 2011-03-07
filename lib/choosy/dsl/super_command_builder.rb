require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/command'

module Choosy::DSL
  class SuperCommandBuilder < BaseCommandBuilder
    HELP = :help
    SUPER = :__SUPER_COMMAND__

    def command(cmd, &block)
      subcommand = if cmd.is_a?(Choosy::Command)
                     cmd
                   else
                     Choosy::Command.new(cmd)
                   end

      if block_given?
        subcommand.builder.instance_eval(&block)
      end
      finalize_subcommand(subcommand)
    end

    def parsimonious
      @command.parsimonious = true
    end

    def metaname(meta)
      @command.metaname = meta
    end

    def help(msg=nil)
      msg ||= "Show the info for a command, or this message"
      help_command = Choosy::Command.new HELP do |help|
        help.summary msg

        help.arguments do
          count 0..1
          validate do |args, options|
            if args.nil? || args.length == 0
              raise Choosy::HelpCalled.new(SUPER)
            else
              require 'pp'
              pp '-------'
              pp args.class
              pp options.class
              pp '-------'
              raise Choosy::HelpCalled.new(args[0])
            end
          end
        end
      end
      finalize_subcommand(help_command)
    end

    def finalize!
      super
      @command.metaname ||= 'COMMAND'
    end

    private
    def finalize_subcommand(subcommand)
      subcommand.builder.finalize!
      @command.command_builders[subcommand.name] = subcommand.builder
      @command.listing << subcommand
      subcommand
    end
  end
end
