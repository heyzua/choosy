require 'choosy/errors'
require 'choosy/printing/terminal'

module Choosy::Printing
  module Manpage
    def frame(cmd_name, manpage, date, platform, subsection)
      ".TH #{cmd_name.to_s.upcase} #{manpage} \"#{date}\" \"#{platform}\" \"#{subsection}\"\n"
    end

    def header(line)
      ".SH #{escape!(line.upcase).gsub!(/:$/, '')}\n"
    end

    def escape(line)
      return if line.nil?
      escape!(line.dup)
    end

    def escape!(line)
      return if line.nil?
      line.gsub!(/-/, "\\-")
      line
    end
  end
end
