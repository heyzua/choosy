require 'spec_helpers'
require 'choosy'

describe "SuperCommand A" do
  before :each do
    @cmd = Choosy::SuperCommand.new :superfoo do |foo|
      foo.para "This is a supercommand of a definite size"
      foo.header 'Commands:'
      
      foo.command :bar do |bar|
        bar.summary "This command is a bar"
        bar.para "This is a description of this subcommand"
        bar.string :favorite_pet, "Your favorite pet."
        bar.boolean :Fuzzy, "Is your pet fuzzy?"
      end

      foo.command :baz do |baz|
        baz.summary "This is a baz command"
        baz.para "This is a description of baz"
        baz.boolean :accountant, "Your accountant who helps you cheat on your taxes"
        baz.integer :amount, "How much money do you save?"
      end

      foo.help

      foo.header 'Options:'
      foo.integer :count, "The Count" do |c|
        c.required
      end
      foo.version "1.ohyeah"
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
    o = capture :stdout do
      @cmd.parse! ['--version']
    end

    require 'pp'
    #pp @cmd.parse! ['--version'], true
    o.should eql("1.ohyeah\n")
  end

  it "should correctly parse the bar command" do
    result = @cmd.parse! ['bar', '--favorite-pet', 'Blue', '--count', '5']
    result.subresults.should have(1).item
    result.subresults[0].options.should eql({:favorite_pet => 'Blue', :Fuzzy => false, :count => 5})
  end
end
