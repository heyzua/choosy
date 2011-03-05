require 'spec_helpers'
require 'choosy'

notes = {:this => 'here'}

describe "SuperCommand A" do
  before :each do
    @cmd = Choosy::SuperCommand.new :superfoo do
      para "This is a supercommand of a definite size"
      header 'Commands:'
      
      command :bar do
        summary notes[:this]
        para "This is a description of this subcommand"
        string :favorite_pet, "Your favorite pet."
        boolean :Fuzzy, "Is your pet fuzzy?"
      end

      command :baz do
        summary "This is a baz command"
        para "This is a description of baz"
        boolean_ :accountant, "Your accountant who helps you cheat on your taxes"
        integer :amount, "How much money do you save?"
      end

      help

      header 'Options:'
      integer :count, "The Count" do
        #required
      end
      version "1.ohyeah"
    end
  end

  it "should fail when a command is not set" do
    o = capture :stderr do
      @cmd.parse! ['blah']
    end

    o.should match(/^superfoo: unrecognized command: 'blah'/)
  end

  it "should fail when parsing a non-existent option" do
    o = capture :stderr do
      @cmd.parse! ['--non-option']
    end

    o.should match(/^superfoo: unrecognized option: '--non-option'/)
  end

  it "should print the version with the given global flag" do
    o = capture { @cmd.parse! ['--version'] }
    o.should eql("1.ohyeah\n")
  end

  it "should correctly parse the bar command" do
    result = @cmd.parse! ['bar', '--favorite-pet', 'Blue', '--count', '5']
    result.subresults.should have(1).item
    result.subresults[0].options.should eql({:favorite_pet => 'Blue', :Fuzzy => false, :count => 5})
  end

  it "should correctly print out the results of the 'help' command" do
    o = capture { @cmd.parse! ['help'] }
    o.should match(/Usage:/)
  end
end
