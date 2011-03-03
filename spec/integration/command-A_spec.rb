require 'spec_helpers'
require 'choosy'

describe "Command A" do
  
  before :each do
    @cmd = Choosy::Command.new :A do |a|
      a.integer :count, "The count"
      a.boolean :bold, "Bold the output"
      a.version "blah"
      a.help
    end
  end

  it "should print a help message"
=begin
do
    o = capture :stdout do
      @cmd.parse! ['--help']
    end

    o.should match /USAGE:/
  end
=end

  it "should handle multiple arguments" do
    result = @cmd.parse! ['--bold', '-c', '5']
    result.options.should eql({:bold => true, :count => 5})
    result.args.should be_empty
    result.unparsed.should be_empty
  end
  
  it "should print out the version number" do
    o = capture :stdout do
      @cmd.parse! ['--count', '5', '--version']
    end

    o.should eql("blah\n")
  end
end
