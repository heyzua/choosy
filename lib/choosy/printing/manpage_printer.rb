require 'choosy/errors'
require 'choosy/option'
require 'choosy/printing/base_printer'

module Choosy::Printing
  class ManpagePrinter
    include BasePrinter

    attr_reader :buffer, :name, :synopsis, :page_number

    def initialize(options={})
      @synopsis = options[:synopsis] || 'SYNOPSIS'
      @name = options[:name] || "NAME"
      @description = options[:description] || "DESCRIPTION"
      @page_number = options[:page_number] || "1"
      @buffer = options[:buffer] || ""
    end
    
    def print!(command)
      format!(command)
      puts @buffer
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
      if !command.summary.nil?
        @buffer << " \\- "
        @buffer << escape(command.summary)
      end
      @buffer << "\n"
    end

    def format_usage(command)
      @buffer << ".SH "
      @buffer << @synopsis
      @buffer << "\n.B "
      @buffer << escape(command.name.to_s)
      command.listing.each do |item|
        if item.is_a? Choosy::Option
          @buffer << escape(usage_option(item))
          @buffer << " "
        end
      end

      case command
      when Choosy::SuperCommand
        @buffer << command.metaname
        @buffer << " "
      when Choosy::Command
        if !command.arguments.nil? && !command.arguments.metaname.nil?
          @buffer << escape(command.arguments.metaname)
        end
      end

      @buffer << "\n"
    end

    def format_listing(command)
      @buffer << ".SH "
      @buffer << @description
      @buffer << "\n"

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
      return if line.nil?
      line.gsub(/-/, "\\-")
    end
  end
end
