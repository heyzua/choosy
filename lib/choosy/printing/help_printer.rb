require 'choosy/errors'
require 'choosy/printing/terminal'
require 'choosy/printing/base_printer'

module Choosy::Printing
  class HelpPrinter < BasePrinter
    attr_reader :buffer, :usage, :line_count

    def initialize(options)
      super(options)

      @buffer = options[:buffer] || ""
      @usage = options[:usage] || 'Usage:'

      @line_count = 0
    end

    def print!(command)
      format!(command)
      if @line_count > lines
        page(@buffer)
      else
        puts @buffer
      end
    end

    def format_prologue(command)
      format_header(@usage)
      @buffer << ' '
      indent = ' ' * (@usage.length + 1)
      usage_wrapped(command, indent, columns).each do |line|
        @buffer << line
        nl
      end
      nl
    end

    def format_epilogue(command)
      nl
      @buffer
    end

    def format_element(element)
      if element.value.nil?
        nl
      elsif element.header?
        nl if @buffer[-2,1] != "\n"
        format_header(element.value, element.styles)
        nl
        nl
      else
        write_lines(element.value, indent, true)
        nl
      end
    end

    def format_option(option, formatted_prefix, opt_indent)
      write_prefix(formatted_prefix, opt_indent)
      write_lines(option.description, opt_indent, false)
    end

    def format_command(command, formatted_prefix, cmd_indent)
      write_prefix(formatted_prefix, cmd_indent)
      write_lines(command.summary, cmd_indent, false)
    end

    def format_header(str, styles=nil)
      return if str.nil?
      if styles && !styles.empty?
        @buffer << color.multiple(str, styles)
      else
        @buffer << color.multiple(str, header_styles)
      end
    end

    protected
    def option_begin
      @option_begin ||= color.multiple(nil, option_styles)
    end

    def option_end
      color.reset
    end

    def nl
      @line_count += 1
      @buffer << "\n"
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
          nl
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
        if line[i, 1] == ' '
          @buffer << line[index, i - index]
          nl
          return i + 1
        end
      end

      # We didn't succeed in writing the line. so just bail and write the rest.
      write_rest(line, index)
    end

    def write_rest(line, index)
      @buffer << line[index, line.length]
      nl
      line.length
    end
  end
end
