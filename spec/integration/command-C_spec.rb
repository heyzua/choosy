require 'choosy'
require 'spec_helpers'

describe "Command C" do
  before :each do
    @cmd = Choosy::Command.new :foo do
      arguments do
        only :tomcat, :apache
      end
    end
  end

  it "should only allow for given arguments" do
    attempting {
      @cmd.parse!(['tomcat', 'no-arg'], true)
    }.should raise_error(Choosy::ValidationError, /unrecognized value/)
  end

  it "should allow a number of arguments" do
    result = @cmd.parse!(['tomcat', 'apache', 'tomcat'])
    result.args.should eql([:tomcat, :apache, :tomcat])
  end
end
