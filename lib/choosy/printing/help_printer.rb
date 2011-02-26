require 'choosy/errors'

module Choosy::Printing
  class HelpPrinter
    def initialize(command)
      @command = command
    end

    def print!(io)
      # Override in subclasses
    end
  end
end
