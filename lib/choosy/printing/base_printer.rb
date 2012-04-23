module Choosy::Printing
  class BasePrinter
    include Choosy::Terminal

    attr_accessor :indent, :offset, :formatting_options, :heading_styles, :option_styles

    def initialize(options)
      @formatting_options = options

      @heading_styles = options[:heading_styles] || [:bold, :blue]
      @option_styles = options[:option_styles] || [:bold]
      @indent = options[:indent] || '  '
      @offset = options[:offset] || '    '

      if options[:color] == false
        self.color.disable!
      end
      if options[:max_width] && self.columns > options[:max_width]
        self.columns = options[:max_width]
      end
    end

    def print!(command)
      page format!(command)
    end

    def format!(command)
      format_prologue(command)

      cmd_indent, option_indent, prefixes = retrieve_formatting_info(command)
      command.listing.each_with_index do |item, i|
        case item
        when Choosy::Option
          format_option(item, prefixes[i], option_indent)
        when Choosy::Command
          format_command(item, prefixes[i], cmd_indent)
        when Choosy::Printing::FormattingElement
          format_element(item)
        end
      end

      format_epilogue(command)
    end

    def line_count
      # Override
    end

    def format_prologue(command)
      # Override
    end

    def format_option(option, formatted_prefix, indent)
      # Override
    end

    def format_command(command, formatted_prefix, indent)
      # Override
    end

    def format_element(item)
      # Override
    end

    def format_epilogue(command)
      # Override
    end

    def usage_option(option, value="")
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
      if option.negated?
        value << '|'
        value << option.negated
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

    def regular_option(option, value="")
      if option.short_flag
        value << highlight_begin
        value << option.short_flag
        value << highlight_end
        if option.long_flag
          value << ', '
        end
      else
        value << '    '
      end

      if option.long_flag
        value << highlight_begin
        if option.negated?
          value << '--['
          value << option.negation
          value << '-]'
          value << option.long_flag.gsub(/^--/, '')
        else
          value << option.long_flag
        end
        value << highlight_end
      end

      if option.metaname
        value << ' '
        value << option.metaname
      end
      value
    end

    def command_name(command)
      if command.is_a?(Choosy::Command) && command.subcommand?
        "#{command.parent.name} #{command.name}"
      else
        "#{command.name}"
      end
    end

    # doesn't indent the first line
    def usage_wrapped(command, indent='', columns=80)
      columns = (columns > 70) ? 70 : columns
      lines = []
      line = command_name(command)
      starting_width = width = line.length + indent.length
      lines << line

      wrap = lambda do |part|
        if width + part.length > columns
          line = ' ' * starting_width
          lines << line
          line << ' ' << part
          width = starting_width + part.length
        else
          line << ' ' << part
          width += part.length
        end
      end

      command.listing.each do |option|
        if option.is_a?(Choosy::Option)
          formatted = usage_option(option)
          wrap.call(formatted)
        end
      end

      case command
      when Choosy::Command
        if command.arguments
          wrap.call(command.arguments.metaname)
        end
      when Choosy::SuperCommand
        wrap.call(command.metaname)
      end

      lines
    end

    protected
    def fix_termcap
      if pager.include?('less')
        headers = color.multiple(nil, @heading_styles)
        options = color.multiple(nil, @option_styles)

        ENV['LESS_TERMCAP_mb'] ||= "\e[31m"       # Begin blinking
        ENV['LESS_TERMCAP_md'] ||= headers        # Begin bold
        ENV['LESS_TERMCAP_me'] ||= "\e[0m"        # End mode
        ENV['LESS_TERMCAP_se'] ||= "\e[0m"        # End STDOUT-mode
        ENV['LESS_TERMCAP_so'] ||= headers        # Begin STDOUT-mode
        ENV['LESS_TERMCAP_ue'] ||= "\e[0m"        # End Underline
        ENV['LESS_TERMCAP_us'] ||= options        # Begin Underline
      end
    end

    def highlight_begin
      ''
    end

    def highlight_end
      ''
    end

    private
    def retrieve_formatting_info(command)
      cmdlen = 0
      optionlen = 0
      prefixes = []

      command.listing.each do |item|
        case item
        when Choosy::Option
          opt = regular_option(item)
          len = unformatted(opt).length
          if len > optionlen
            optionlen = len
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
  end
end
