require 'choosy/errors'
require 'choosy/printing/terminal'
require 'choosy/printing/formatter'

module Choosy::Printing
  class HelpPrinter
    include Terminal
    include Formatter

    attr_accessor :header_attrs

    def print!(command)
      print_usage(command)
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
      print_header('usage: ')
      $stdout << command.name
      $stdout << ' '
      return if command.options.empty?

      width = starting_with = 8 + command.name.length # So far
      command.listing.each do |option|
        if option.is_a?(Choosy::Option)
          formatted = usage(option)
        end
      end
    end

    def print_option(option)
      $stdout << "  "
      if option.short_flag
        $stdout << option.short_flag
        if option.long_flag
          $stdout << ", "
        end
      end

      if option.long_flag
        $stdout << option.long_flag
      end

      if option.metaname
        $stdout << " "
        $stdout << option.metaname
      end

      $stdout << "\n"
      write_lines(option.description, "       ")
    end

    def print_command(command)
      write_lines("#{command.name}\t#{command.summary}", "  ")
    end

    def print_header(str, attrs=nil)
      return if str.nil?

      if color.disabled?
        $stdout << str
        return
      end

      attrs.each do |attr|
       $stdout << color.send(attr)
      end if attrs

      header_attrs.each do |attr|
        $stdout << color.send(attr)
      end if header_attrs
      
      $stdout << str
      if attrs || header_attrs
        $stdout << color.reset
      end
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
  end
end
