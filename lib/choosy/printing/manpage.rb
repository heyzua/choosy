require 'choosy/errors'
require 'choosy/option'
require 'choosy/printing/base_printer'

module Choosy::Printing
  class Manpage
    include BasePrinter

    attr_reader :buffer, :name, :synopsis, :page_number

    def initialize(options={})
      @synopsis = options[:synopsis] || 'Synopsis:'
      @name = options[:namd] || "Name:"
      @page_number = options[:page_number] || "1"
      @buffer = options[:buffer] || ""
    end
    
    def print!(command)
      format!(command)
      # TODO: Output via groff
    end

    def format!(command)
      format_preamble(command)
      format_usage(command)
      format_listing(command)
    end

    def format_preamble(command)
      cname = escape(command.name.to_s)
      @buffer << ".TH "
      @buffer << cname
      @buffer << "(#{@page_number})\n"
      @buffer << ".SH "
      @buffer << @name
      @buffer << "\n"
      @buffer << cname
      @buffer << " \\- "
      @buffer << escape(command.summary)
      @buffer << "\n"
    end

    def format_usage(command)
      @buffer << ".SH "
      @buffer << @synopsis
      @buffer << "\n.B "
      @buffer << escape(command.name.to_s)
      @buffer << "\n"
      command.listing.each do |item|
        if Choosy::Option === item
          @buffer << escape(usage_option(item))
          @buffer << " "
        end
      end

      if !command.arguments.nil? && !command.arguments.metaname.nil?
        @buffer << escape(command.arguments.metaname)
      end

      @buffer << "\n"
    end

    def format_listing(command)
      encountered_option = false
      command.listing.each do |item|
        case item
        when Choosy::Option
          if !encountered_option
            encountered_option = true
            @buffer << ".TP\n"
          end
          format_option(item)
        when Choosy::Printing::FormattingElement
          encountered_option = false
          if item.header?
            format_header(item)
          else
            format_para(item)
          end
        when Choosy::Command
          encountered_option = false
          format_command(item)
        end
      end
    end

    def format_option(option)
      @buffer << ".BI "
      @buffer << escape(regular_option(option))
      @buffer << "\n"
      @buffer << escape(option.description)
      @buffer << "\n"
    end

    def format_header(fo)
      @buffer << ".SH "
      @buffer << fo.value
      @buffer << "\n"
    end

    def format_para(fo)
      if fo.value.nil?
        @buffer << ".PP\n"
      else
        @buffer << fo.value
        @buffer << "\n"
      end
    end

    def format_command(cmd)
      @buffer << "\\fI"
      @buffer << escape(cmd.name.to_s)
      @buffer << "\\fP\t"
      @buffer << cmd.summary
      @buffer << "\n"
    end

    protected
    def escape(line)
      line.gsub(/-/, "\\-")
    end
  end
end
