require 'choosy/errors'
require 'choosy/printing/color'

module Choosy::Printing
  module Terminal
    DEFAULT_LINE_COUNT = 25
    DEFAULT_COLUMN_COUNT = 80

    def lines
      @lines ||= find_terminal_size('LINES', 'lines', 0) || DEFAULT_LINE_COUNT
    end

    def lines=(value)
      @lines = value
    end

    def columns
      @columns ||= find_terminal_size('COLUMNS', 'cols', 1) || DEFAULT_COLUMN_COUNT
    end

    def columns=(value)
      @columns = value
    end

    def color
      @color ||= Color.new
    end

    # directly from hirb
    def command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end

    private
    # https://github.com/cldwalker/hirb
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
  end
end
