require 'choosy/errors'

module Choosy::Printing
  class ManpageFormatter
    def bold(line=nil)
      if line.nil?
        '\\fB'
      else
        "\\fB#{line}\\fP"
      end
    end

    def italics(line=nil)
      if line.nil?
        '\\fI'
      else
        "\\fI#{line}\\fP"
      end
    end

    def roman(line=nil)
      if line.nil?
        '\\fR'
      else
        "\\fR#{line}\\fP"
      end
    end

    def reset
      '\\fP'
    end
  end

  class Manpage
    attr_accessor :name, :section, :date, :version, :manual
    attr_reader :format, :buffer

    def initialize
      @buffer = []
      @section = 1
      @format = ManpageFormatter.new
      @version = nil
      @date = nil
      @manual = nil
    end

    def frame_outline
      frame = ".TH"
      quote(frame, @name)
      quote(frame, @section)
      quote(frame, @date)
      quote(frame, @version)
      quote(frame, @manual)
      frame
    end

    def section_heading(line)
      prefixed('.SH', heading(line))
    end

    def subsection_heading(line)
      prefixed('.SS', heading(line))
    end

    def paragraph(line=nil)
      line = if line.nil?
               '.P'
             else
               ".P\n" << line
             end
      append(line)
    end

    def indented_paragraph(item, line)
      prefixed('.IP', escape(item), escape(line))
    end

    def hanging_paragraph(line)
      append(".HP\n" << escape(line))
    end

    def indented_region
      append('.RE')
    end

    def text(line)
      return if line.nil?
      append(escape(line))
    end

    def raw(line)
      return if line.nil?
      append(line)
    end

    def bold(line, type=nil)
      line = escape(line)
      case type
      when nil
        prefixed('.B', line)
      when :italics
        prefixed('.BI', line)
      when :roman
        prefixed('.BR', line)
      else
        raise Choosy::ConfigurationError.new("Undefined manpage bold type: #{type}")
      end
    end

    def italics(line, type=nil)
      line = escape(line)
      case type
      when nil
        prefixed('.I', line)
      when :bold
        prefixed('.IB', line)
      when :roman
        prefixed('.IR', line)
      else
        raise Choosy::ConfigurationError.new("Undefined manpage italics type: #{type}")
      end
    end

    def roman(line, type)
      line = escape(line)
      case type
      when :italics
        prefixed('.RI', line)
      when :bold
        prefixed('.RB', line)
      else
        raise Choosy::ConfigurationError.new("Undefined manpage for roman type: #{type}")
      end
    end

    def small(line, type=nil)
      line = escape(line)
      case type
      when nil
        prefixed('.SM', line)
      when :bold
        prefixed('.SB', line)
      else
        raise Choosy::ConfigurationError.new("Undefined manpage for small type: #{type}")
      end
    end

    def comment(line)
      append('.\\" ' << line)
    end

    def line_break
      append('.br')
    end

    def nofill(&block)
      if block_given?
        append('.nf')
        yield self
        append('.fi')
      else
        append('.nf')
      end
    end

    def fill
      append('.fi')
    end

    def term_paragraph(term, para, width=5)
      append(".TP " << width.to_s << NEWLINE << escape(term) << NEWLINE << escape(para))
    end

    def to_s(io=nil)
      io ||= ""
      io << "'\\\" t\n"
      io << frame_outline << NEWLINE
      io << PREFACE
      @buffer.each do |line|
        io << line
        io << NEWLINE
      end
      io
    end

    private
    # Taken from the Debian best practices
    PREFACE =<<EOF
.ie \\n(.g .ds Aq \\(aq
.el       .ds Aq '
.\\" disable hyphenation
.nh
.\\" disable justification (adjust text to left margin only)
.ad l
EOF
    SQUOTE = ' "'
    EQUOTE = '"'
    NEWLINE = "\n"

    def quote(base, val)
      if val 
        base << SQUOTE << val.to_s << EQUOTE
      else
        base << SQUOTE << ' ' << EQUOTE
      end
    end

    def prefixed(tag, quot, line=nil)
      puts tag if quot.nil?
      tag << SQUOTE << quot << EQUOTE
      if line.nil?
        append(tag)
      else
        append(tag << NEWLINE << line)
      end
    end

    def append(line)
      @buffer << line
      line
    end

    def escape(line)
      nline = line.gsub(/-/, "\\-")
      nline.gsub!(/(\.+)/, '&\1')
      nline
    end

    def heading(line)
      nline = escape(line)
      nline.upcase!
      nline.gsub!(/:$/, '')
      nline
    end
  end
end
