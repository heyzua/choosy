require 'spec_helpers'
require 'choosy'

describe "SuperCommand C" do
  class SuperCommandC
    def super_command
      Choosy::SuperCommand.new :super do
        default :subA

        command subA
        command subB
        command :help

        boolean :option, "Option" do
          desc option_name
        end
      end
    end

    def subA
      Choosy::Command.new :subA do
        string :sub_option, "Sub option" do
          desc option_name
        end
      end
    end

    def subB
      Choosy::Command.new :subB do
      end
    end

    def option_name
      "an option name"
    end
  end

  before :each do
    @sup = SuperCommandC.new.super_command
  end

  it "should set the option name correctly" do
    @sup.option_builders[:option].entity.description.should eql("an option name")
  end

  it "should set the sub-option name correctly" do
    @sup.command_builders[:subA].entity.option_builders[:sub_option].entity.description.should eql("an option name")
  end

  it "should return the default command on parse" do
    @sup.parse!(['-o'], true).subresults[0].command.name.should eql(:subA)
  end
end
