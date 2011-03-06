require 'choosy'
require 'spec_helpers'

describe "SuperCommand B" do
  before :each do
    @s = Choosy::SuperCommand.new :super do
      header 'Commands:'
      command :bar do
        arguments do
          count 0..1
        end
      end
      command :foo
    end
  end

  it "should leave 'foo' as an argument to bar when not parsimonious" do
    res = @s.parse! ['bar', 'foo']
    res.subresults.should have(1).items
    res.subresults[0].args.should eql(['foo'])
  end

  it "should have 2 subresults when parsimonious" do
    @s.alter do
      parsimonious
    end

    res = @s.parse! ['bar', 'foo']
    res.subresults.should have(2).items
    res.subresults[0].args.should be_empty
  end
end
