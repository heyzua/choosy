require 'spec_helpers'
require 'choosy'

describe "SuperCommand C" do
  class SuperCommandC
    def super_command
      Choosy::SuperCommand.new :super do

        command subA
        command subB

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

  it "should set the option name correctly" do
    sup = SuperCommandC.new.super_command
    sup.option_builders[:option].entity.description.should eql("an option name")
  end

  it "should set the sub-option name correctly" do
    sup = SuperCommandC.new.super_command
    sup.command_builders[:subA].entity.option_builders[:sub_option].entity.description.should eql("an option name")
  end
end
