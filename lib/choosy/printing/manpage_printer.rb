require 'choosy/errors'
require 'choosy/option'
require 'choosy/dsl/option_builder'
require 'choosy/printing/base_printer'
require 'choosy/printing/manpage'

module Choosy::Printing
  class ManpagePrinter
    include BasePrinter

    attr_reader :buffer, :name, :synopsis

    def initialize(options={})
      @name = options[:name] || "NAME"
      @synopsis = options[:synopsis] || 'SYNOPSIS'
      @description = options[:description] || "DESCRIPTION"

      @manpage = Manpage.new
      @manpage.section = options[:section] || 1
      @manpage.date = options[:date]
      @manpage.manual = options[:manual]
    end
    
    def print!(command)
      format!(command)
      # TODO: Output via groff
    end

    def format!(command)
      @manpage.name = command.name.to_s
      version_option = command.builder.command_builders[Choosy::DSL::OptionBuilder::VERSION]
      if version_option
        @manpage.version = version_option.entity.default_value
      end

      format_name(command)
      format_synosis(command)
      format_description(command)
      format_listing(command)
    end

    def format_name(command)
      if command.summary
        @manpage.section_header(@name)
        @manpage.text("#{command.name} - #{command.summary}")
      end
    end

    def format_synopsis(command)
      @manpage.section_header(@synopsis)
      cname = command.name.to_s
      indent = ' ' * (cname.length + 1)
      @manpage.nofill
      usage = @manpage.format.italics(cname)
      usage << ' '
      @manpage.fill
    end

  end
end
