require 'choosy/errors'
require 'choosy/printing/color'

module Choosy::Printing
  class HelpPrinter
    DEFAULT_LINE_COUNT = 25
    DEFAULT_COLUMN_COUNT = 80

    attr_reader :color

    def initialize
      @color = Color.new
    end
  
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

    def colored=(val)
      @color.disable! unless val
    end

    def print!(command)
      print_usage(command)
      print_summary(command.summary) if command.summary
      print_description(command.description) if command.description
      command.listing.each do |l|
        if l.is_a?(String)
          print_separator(l)
        elsif l.is_a?(Choosy::Option)
          print_option(l)
        else
          print_command(l)
        end
      end
    end

    def print_usage(command)
      args = if command.argument_validation
               " [ARGS]"
             else
               ""
             end
      options = if command.option_builders.length == 0
                  ""
                else
                  " [OPTIONS]"
                end
      $stdout << "Usage: #{command.name}#{options}#{args}\n"
    end

    def print_summary(summary)
      print_separator(summary)
    end

    def print_description(desc)
      $stdout << "Description:\n"
      write_lines(desc, "    ")
    end

    def print_separator(sep)
      $stdout << "#{sep}\n"
    end

    def print_option(option)
      $stdout << "    "
      if option.short_flag
        $stdout << option.short_flag
        if option.long_flag
          $stdout << ", "
        end
      end

      if option.long_flag
        $stdout << option.long_flag
      end

      if option.flag_parameter
        $stdout << " "
        $stdout << option.flag_parameter
      end

      $stdout << "\n"
      write_lines(option.description, "        ")
    end

    def print_command(command)
      raise "Whoa!!!!"
    end

    protected
    def write_lines(str, prefix)
      str.split("\n").each do |line|
        if line.length == 0
          $stdout << "\n"
        else
          wrap_long_lines(line, prefix)
        end
      end
    end

    # FIXME: not exactly pretty, but it works, mostly
    MAX_BACKTRACK = 25
    def wrap_long_lines(line, prefix)
      index = 0
      while index < line.length
        segment_size = line.length - index
        if segment_size >= columns
          i = columns + index - prefix.length
          while i > columns - MAX_BACKTRACK
            if line[i] == ' '
              indent_line(line[index, i - index], prefix)
              index = i + 1
              break
            else
              i -= 1
            end
          end
        else
          indent_line(line[index, line.length], prefix)
          index += segment_size
        end
      end
    end

    def indent_line(line, prefix)
      $stdout << prefix
      $stdout << line
      $stdout << "\n"
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

    # directly from hirb
    def command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end
  end
end
