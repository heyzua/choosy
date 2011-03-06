require 'choosy'
require 'spec_helpers'

describe "Command B" do
  before :each do
    @c = Choosy::Command.new :foo do
      strings :many_args, "The many arguments"
      help

      arguments do
        required
        count 2..3
        validate do |args, options|
          if !args.include?("here")
            die("Should have found 'here'")
          end
        end
      end
    end
  end

  it "should succeed when there are exactly three arguments" do
    attempting {
      @c.parse! ['this', 'is', 'here'], true
    }.should_not raise_error
  end

  it "should fail when 'here' isn't in the argument list" do
    attempting {
      @c.parse! ['this', "isn't", 'happening'], true
    }.should raise_error(Choosy::ValidationError, /'here'/)
  end

  it "should fail when there are too few arguments" do
    attempting {
      @c.parse! ['here'], true
    }.should raise_error(Choosy::ValidationError, /too few/)
  end

  it "should fail when there are too many arguments" do
    attempting {
      @c.parse! ['here', 'is', 'a', 'list'], true
    }.should raise_error(Choosy::ValidationError, /too many/)
  end
end
