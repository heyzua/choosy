require 'choosy/errors'
require 'choosy/option'
require 'choosy/dsl/option_builder'
require 'choosy/printing/base_printer'
require 'choosy/printing/manpage'

module Choosy::Printing
  class ManpagePrinter < BasePrinter
    attr_reader :manpage, :name, :synopsis

    def initialize(options={})
      super(options)

      @name = options[:name] || "NAME"
      @synopsis = options[:synopsis] || 'SYNOPSIS'

      @manpage = Manpage.new
      @manpage.section = options[:section] || 1
      @manpage.date = options[:date]
      @manpage.manual = options[:manual]
      @manpage.version = options[:version] 
    end
    
    def print!(command)
      if command_exists?('groff') && pager?
        fix_termcap
        page format!(command), 'groff -t -e -W all -Tutf8 -mandoc'
      else
        # Fall back to a help printer if there is no pager
        help = HelpPrinter.new(formatting_options)
        help.print!(command)
      end
    end

    def format_prologue(command)
      @manpage.name = command_name(command)
      version_option = command.option_builders[Choosy::DSL::OptionBuilder::VERSION]
      if version_option && @manpage.version.nil?
        begin
          version_option.entity.validation_step.call(nil, nil)
        rescue Choosy::VersionCalled => e
          @manpage.version = e.message
        end
      end

      format_name(command)
      format_synopsis(command)
    end

    def format_name(command)
      if command.summary
        @manpage.section_heading(@name)
        @manpage.text("#{command.name} - #{command.summary}")
      end
    end

    def format_synopsis(command)
      @manpage.section_heading(@synopsis)
      @manpage.nofill do |man|
        usage_wrapped(command, '', columns).each do |line|
          man.text line
        end
      end
    end

    def format_option(option, formatted_option, indent)
      @manpage.term_paragraph(formatted_option, option.description, indent.length)
    end

    def format_command(command, formatted_command, indent)
      @manpage.term_paragraph(formatted_command, command.summary || "", indent.length)
    end

    def format_element(item)
      if item.header?
        @manpage.section_heading(item.value)
      else
        @manpage.paragraph(item.value)
      end
    end

    def format_epilogue(command)
      @manpage.to_s
    end

    protected
    def option_begin
      @manpage.format.italics
    end

    def option_end
      @manpage.format.reset
    end
  end
end
