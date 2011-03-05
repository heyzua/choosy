require 'choosy/errors'
require 'choosy/dsl/base_command_builder'
require 'choosy/command'

module Choosy::DSL
  class SuperCommandBuilder < BaseCommandBuilder
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

    def help(msg=nil)
      msg ||= "Show the info for a command, or this message"
      help = Choosy::Command.new :help do |help|
        help.summary msg

        help.arguments do |args|
          if args.nil? || args.length == 0
            raise Choosy::HelpCalled.new
          else
            raise Choosy::HelpCalled.new(args[0].to_sym)
          end
        end
      end
      finalize_subcommand(help)
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
