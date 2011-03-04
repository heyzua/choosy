require 'choosy/errors'
require 'choosy/printing/terminal'
require 'choosy/printing/formatter'

module Choosy::Printing
  class HelpPrinter
    include Terminal
    include Formatter

    attr_accessor :header_attrs, :indent, :offset

    def initialize
      @indent = '  '
      @offset = '  '
    end

    def print!(command)
      print_usage(command)

      max_cmd_length, option_indent, option_lines = retrieve_formatting_info(command)

      command.listing.each_with_index do |item, i|
        case item
        when Choosy::Option
          print_option(item, option_lines[i], option_indent)
        when Choosy::Command
          print_command(item, max_cmd_length)
        when Choosy::Printing::FormattingElement
          print_element(item)
        end
      end
    end

    def print_usage(command)
      print_header('usage: ')
      $stdout << command.name
      return if command.options.empty?

      width = starting_width = 8 + command.name.length # So far
      command.listing.each do |option|
        if option.is_a?(Choosy::Option)
          formatted = usage_option(option)
          width += formatted.length
          if width > columns
            $stdout << "\n"
            $stdout << ' ' * starting_width
            $stdout << formatted
            width = starting_width + formatted.length
          else
            $stdout << ' '
            $stdout << formatted
            width += 1
          end
        end
      end

      $stdout << "\n"
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

    def print_element(element)
      if element.header?
        $stdout << "\n"
        print_header(element.value, element.attrs)
        $stdout << "\n"
      else
        $stdout << "\n"
        write_lines(element.value, indent)
      end
    end

    def print_option(option, formatted_prefix, opt_indent)
      len = opt_indent.length - formatted_prefix.length - indent.length 
      line = "#{indent}#{formatted_prefix}" + (' ' * len) + option.description
      write_lines(line, opt_indent, true)
    end

    protected
    def write_lines(str, prefix, skip_first=nil)
      str.split("\n").each do |line|
        if line.length == 0
          $stdout << "\n"
        else
          wrap_long_lines(line, prefix, skip_first)
        end
      end
    end

    def retrieve_formatting_info(command)
      cmdlen = 0
      optionlen = 0
      options = []

      command.listing.each do |item|
        case item
        when Choosy::Option
          opt = regular_option(item)
          if opt.length > optionlen
            optionlen = opt.length
          end
          options << opt
        when Choosy::Command
          if item.name.length > cmdlen
            cmdlen = item.name.length
          end
          options << nil
        else
          options << nil
        end
      end

      option_indent = ' ' * (optionlen + indent.length + offset.length)
      [cmdlen, option_indent, options]
    end

    # FIXME: not exactly pretty, but it works, mostly
    MAX_BACKTRACK = 25
    def wrap_long_lines(line, prefix, skip_first=nil)
      index = 0

      indent = !skip_first

      while index < line.length
        segment_size = line.length - index
        if segment_size >= columns
          i = if indent
                columns + index - prefix.length
              else
                columns + index
              end
          while i > columns - MAX_BACKTRACK
            if line[i] == ' '
              indent = write_line(line[index, i - index], prefix, indent)
              index = i + 1
              break
            else
              i -= 1
            end
          end
        else
          indent = write_line(line[index, line.length], prefix, indent)
          index += segment_size
        end
      end
    end

    def write_line(line, prefix, indent)
      $stdout << prefix if indent
      $stdout << line
      $stdout << "\n"
      true
    end
  end
end
