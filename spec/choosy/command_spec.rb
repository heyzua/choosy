require 'spec_helpers'
require 'choosy/command'
require 'choosy/printing/help_printer'

module Choosy
  describe Command do
    before :each do
      @c = Command.new :foo
    end

    describe :parse! do
      it "should print out the version number" do
        @c.alter do |c|
          c.version "blah"
        end

        o = capture :stdout do
          attempting {
            @c.parse!(['--version'])
          }.should raise_error(SystemExit)
        end

        o.should eql("blah\n")
      end

      it "should print out the help info" do
        @c.alter do |c|
          c.summary "Summary"
          c.help
        end

        o = capture :stdout do
          attempting {
            @c.parse!(['--help'])
          }.should raise_error(SystemExit)
        end

        o.should match(/-h, --help/)
      end
    end

    describe :execute! do
      it "should fail when no executor is given" do
        attempting {
         @c.execute!(['a', 'b'])
        }.should raise_error(Choosy::ConfigurationError, /No executor/)
      end
    end
  end
end
