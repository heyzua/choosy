require 'spec_helpers'
require 'choosy/command'

module Choosy
  describe BaseCommand do
    before :each do
      @cmd = Command.new :cmd
    end

    describe :finalize! do
      it "should set the printer if not already set" do
        @cmd.finalize!
        @cmd.printer.should be_a(Choosy::Printing::HelpPrinter)
      end
    end#finalize!

    it "should order the options in dependency order" do
      @cmd.alter do
        integer :count, "Count" do
          depends_on :bold
        end

        boolean :bold, "Bold" do
          depends_on :font, :config
        end

        symbol :font, "Font" do
          depends_on :config
        end

        file :config, "The config"
        file :access, "Access code" do
          depends_on :config, :count
        end
      end

      @cmd.options.map {|o| o.name}.should eql([:config, :font, :bold, :count, :access])
    end
  end
end
