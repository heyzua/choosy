require 'spec_helpers'
require 'choosy/command'

module Choosy
  describe BaseCommand do
    it "should finalize the builder" do
      cmd = Command.new :cmd
      cmd.printer.should be_a(Choosy::Printing::HelpPrinter)
    end 
  end
end
