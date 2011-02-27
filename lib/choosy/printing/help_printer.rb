require 'choosy/errors'

module Choosy::Printing
  class HelpPrinter
    DEFAULT_LINE_COUNT = 25
    DEFAULT_COLUMN_COUNT = 80

    def initialize
      @colored = true 
    end

    # https://github.com/cldwalker/hirb
    def lines
      @lines ||= find_terminal_size('LINES', 'lines', 0) || DEFAULT_LINE_COUNT
    end

    def columns
      @columns ||= find_terminal_size('COLUMNS', 'cols', 1) || DEFAULT_COLUMN_COUNT
    end

    def colored=(val)
      @colored = val
    end

    def colored?
      @colored
    end

    def print!(command, io)
      # Override in subclasses
    end

    private 
    # modified from hirb
    def find_terminal_size(env_name, tput_name, stty_index)
      begin 
        if ENV[env_name] =~ /^\d$/
          ENV[env_name].to_i
        elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
          `tput #{tput_name}`.to_i
        elsif STDIN.tty? && command_exists?('stty')
          `stty size`.scan(/\d+/).map { |s| s.to_i }[stty_index]
        else
          nil
        end
      rescue
        nil
      end
    end

    # directly from hirb
    def command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end
  end
end
