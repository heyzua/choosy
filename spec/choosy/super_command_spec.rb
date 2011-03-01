require 'spec_helpers'
require 'choosy/super_command'

module Choosy
  describe SuperCommand do
    before :each do 
      @c = SuperCommand.new :superfoo
    end

    describe :parse! do
      it "should be able to print out the version number" do
        @c.alter do |c|
          c.version "superblah"
        end

        o = capture :stdout do
          attempting {
            @c.parse!(['--version'])
          }.should raise_error(SystemExit)
        end

        o.should eql("superblah\n")
      end

      it "should print out the supercommand help message"
      it "should print out a subcommand help message"
      it "should raise a HelpCalled when it has a :help command" 
      it "should raise a CommandLineError when a :help command is absent"
      
    end

    describe :execute! do
      it "should find the right command to execute"
      it "should fail if it can't find the right command to execute"
    end
  end
end
