require 'choosy/errors'
require 'choosy/printing/help_printer'
require 'erb'

module Choosy::Printing
  class ERBPrinter < HelpPrinter
    attr_reader :command
    attr_accessor :template

    def print!(command)
      @command = command
      contents = nil
      File.open(template, 'r') {|f| contents = f.read }
      erb = ERB.new contents

      erb.run(self)
    end

    def erb_binding
      binding
    end
  end
end
