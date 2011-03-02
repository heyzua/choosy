require 'spec_helpers'
require 'choosy'

describe "SuperCommand A" do
  before :each do
    @cmd = Choosy::SuperCommand.new :superfoo do |foo|
      foo.desc "This is a supercommand of a definite size"
      foo.separator 'Commands:'
      
      foo.command :bar do |bar|
        bar.summary "This command is a bar"
        bar.desc "This is a description of this subcommand"
        bar.string :favorite_pet, "Your favorite pet."
        bar.boolean :Fuzzy, "Is your pet fuzzy?"
      end

      foo.command :baz do |baz|
        baz.summary "This is a baz command"
        baz.desc "This is a description of baz"
        baz.boolean :accountant, "Your accountant who helps you cheat on your taxes"
        baz.integer :amount, "How much money do you save?"
      end

      foo.help

      foo.separator 'Options:'
      foo.version "1.ohyeah"
    end
  end
=begin
  it "should fail when a command is not set" do
    o = capture :stderr do
      @cmd.parse! ['blah']
    end

    o.should match(/^superfoo: 'blah' is not a standard command/)
  end

  it "should fail when parsing a non-existent option" do
    o = capture :stderr do
      @cmd.parse! ['--non-option']
    end

    o.should match(/^superfoo: '--non-option' is not a standard/)
  end

  it "should print the version with the given global flag" do
    o = capture :stdout do
      @cmd.parse! ['--version']
    end

    o.should eql("1.ohyeah\n")
  end

  it "should correctly parse the bar command" do
    results = @cmd.parse! ['bar', '--favorite-pet', 'Blue']
    results.should have(1).item
    result[0].options.should eql({:favorite_pet => 'Blue', :Fuzzy => false})
  end
=end
end
