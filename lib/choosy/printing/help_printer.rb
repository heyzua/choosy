require 'choosy/errors'
require 'choosy/printing/terminal'

module Choosy::Printing
  class HelpPrinter
    include Terminal

    attr_reader :header_styles, :indent, :offset, :buffer, :usage

    def initialize(options)
      @indent = options[:indent] || '  '
      @offset = options[:offset] || '  '
      @header_styles = options[:header_styles] || [:bold, :blue]
      @buffer = options[:buffer] || ""
      @usage = options[:usage] || 'Usage:'

      if options[:color] == false
        color.disable!
      end
      if options[:max_width]
        self.columns = options[:max_width]
      end
    end

    def print!(command)
      print_usage(command)

      cmd_indent, option_indent, prefixes = retrieve_formatting_info(command)

      command.listing.each_with_index do |item, i|
        case item
        when Choosy::Option
          print_option(item, prefixes[i], option_indent)
        when Choosy::Command
          print_command(item, prefixes[i], cmd_indent)
        when Choosy::Printing::FormattingElement
          print_element(item)
        end
      end

      @buffer
    end

    def print_usage(command)
      print_header(@usage)
      @buffer << ' '
      @buffer << command.name.to_s
      return if command.options.empty?

      width = starting_width = 8 + command.name.length # So far
      command.listing.each do |option|
        if option.is_a?(Choosy::Option)
          formatted = usage_option(option)
          width += formatted.length
          if width > columns
            @buffer << "\n"
            @buffer << ' ' * starting_width
            @buffer << formatted
            width = starting_width + formatted.length
          else
            @buffer << ' '
            @buffer << formatted
            width += 1
          end
        end
      end

      @buffer << "\n"
    end

    def print_header(str, styles=nil)
      return if str.nil?
      if styles && !styles.empty?
        @buffer << color.multiple(str, styles)
      else
        @buffer << color.multiple(str, header_styles)
      end
    end

    def print_element(element)
      if element.header?
        @buffer << "\n"
        print_header(element.value, element.styles)
        @buffer << "\n"
      else
        @buffer << "\n"
        write_lines(element.value, indent, true)
      end
    end

    def print_option(option, formatted_prefix, opt_indent)
      write_prefix(formatted_prefix, opt_indent)
      write_lines(option.description, opt_indent, false)
    end

    def print_command(command, formatted_prefix, cmd_indent)
      write_prefix(formatted_prefix, cmd_indent)
      write_lines(command.summary, cmd_indent, false)
    end

    def usage_option(option, value=nil)
      value ||= ""
      value << "["
      if option.short_flag
        value << option.short_flag
        if option.long_flag
          value << "|"
        end
      end
      if option.long_flag
        value << option.long_flag
      end
      if option.metaname
        if option.arity.max > 1
          value << ' '
          value << option.metaname
        else
          value << '='
          value << option.metaname
        end
      end
      value << ']'
    end

    def regular_option(option, value=nil)
      value ||= ""
      if option.short_flag
        value << option.short_flag
        if option.long_flag
          value << ', '
        end
      else
        value << '    '
      end

      if option.long_flag
        value << option.long_flag
      end

      if option.metaname
        value << ' '
        value << option.metaname
      end
      value
    end

    protected
    def retrieve_formatting_info(command)
      cmdlen = 0
      optionlen = 0
      prefixes = []

      command.listing.each do |item|
        case item
        when Choosy::Option
          opt = regular_option(item)
          if opt.length > optionlen
            optionlen = opt.length
          end
          prefixes << opt
        when Choosy::Command
          name = item.name.to_s
          if name.length > cmdlen
            cmdlen = name.length
          end
          prefixes << name
        else
          prefixes << nil
        end
      end

      option_indent = ' ' * (optionlen + indent.length + offset.length)
      cmd_indent = ' ' * (cmdlen + indent.length + offset.length)
      [cmd_indent, option_indent, prefixes]
    end

    def write_prefix(prefix, after_indent)
      len = after_indent.length - prefix.length - indent.length
      @buffer << indent
      @buffer << prefix
      @buffer << ' ' * len
    end

    def write_lines(str, prefix, indent_first)
      str.split("\n").each do |line|
        if line.length == 0
          @buffer << "\n"
        else
          index = 0

          while index < line.length
            index = write_line(line, prefix, index, indent_first)
            indent_first = true
          end
        end
      end
    end

    # Line:
    #    index                          char
    # ----|---------------|--------------|--------------------|
    #                  length?                             length?
    # 
    # Printing:
    #  offset                                          columns
    # --|-------------------------------------------------|
    #
    MAX_BACKTRACK = 25
    def write_line(line, prefix, index, indent_first)
      if indent_first
        @buffer << prefix
      end

      max_line_length = columns - prefix.length # How much can we print?
      char = index + max_line_length # Where are we within the line, looking at the max length

      if char > line.length # There's not a lot of line left to print
        return write_rest(line, index)
      end

      char.downto(char - MAX_BACKTRACK) do |i| # Only go back a fixed line segment
        if line[i] == ' '
          @buffer << line[index, i - index]
          @buffer << "\n"
          return i + 1
        end
      end

      # We didn't succeed in writing the line. so just bail and write the rest.
      write_rest(line, index)
    end

    def write_rest(line, index)
      @buffer << line[index, line.length]
      @buffer << "\n"
      line.length
    end
  end
end
