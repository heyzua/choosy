require 'choosy/errors'

module Choosy::Completions
  class BashCompleter
    def self.build
      return nil unless ENV['COMP_WORDS']

      words = ENV['COMP_WORDS'].split # FIXME: Split according to CLI
      line = ENV['COMP_LINE'] 
      point = ENV['COMP_POINT'].to_i
      cword = ENV['COMP_CWORD'].to_i

      if words && line && point && cword
        BashCompleter.new(words, line, point, cword)
      else
        nil
      end
    end

    attr_reader :words, :line, :point, :cword

    def initialize(words, line, point, cword)
      @words = words
      @line = line
      @point = point
      @cword = cword
    end

    def current_word
      @words[cword]
    end

    def complete_for(command)
      if current_word.nil?
        gather_flags(command, gather_subcommands(command))
      elsif current_word.start_with?('-')
        gather_flags(command).delete_if {|p| !p.start_with?(current_word)}
      end
    end

    private
    def gather_flags(command, result = [])
      command.option_builders.values.each do |builder|
        opt = builder.entity
        result << opt.short_flag if opt.short_flag 
        result << opt.long_flag if opt.long_flag
      end

      if cmd = previous_subcommand(command)
        gather_flags(cmd, result)
      end

      result
    end

    def gather_subcommands(command)
      result = []
      each_subcommand(command) do |cmd, name|
        result << name
        nil
      end
      result
    end

    def previous_subcommand(command)
      found = nil
      each_subcommand(command) do |cmd, name|
        cword.downto(0) do |i|
          return cmd if name == @words[i]
        end
      end
      found
    end

    def each_subcommand(command, &block)
      if command.is_a?(Choosy::SuperCommand)
        command.command_builders.values.each do |builder|
          b = yield builder.entity, builder.entity.name.to_s
          break if b
        end
      else
        nil
      end
    end
  end
end
