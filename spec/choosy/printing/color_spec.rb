require 'spec_helpers'
require 'choosy/printing/color'

module Choosy::Printing
  describe Color do
    before :each do
      @c = Color.new
    end

    it "should be enabled when run from the command line" do
      @c.disabled?.should be(false)
    end

    it "should not respond to random colors" do
      attempting {
        @c.non_color
      }.should raise_error(NoMethodError)
    end
  
    it "should respond to colors" do
      Color::COLORS.each_key do |k|
        @c.respond_to?(k).should be(true)
      end
    end

    it "should respond to effects" do
      Color::EFFECTS.each_key do |k|
        @c.respond_to?(k).should be(true)
      end
    end
    
    it "should return the string itself if not enabled" do
      @c.disable!
      @c.red("this").should eql("this")
    end

    it "should return an empty string if not enabled" do
      @c.disable!
      @c.red.should eql("")
    end

    it "should fail on too many arguments" do
      attempting {
        @c.red("string", :foreground, "extra")
      }.should raise_error(ArgumentError, /Color#red/)
    end

    it "should fail when setting a style not foreground or background" do
      attempting {
        @c.red("string", :no_method) 
      }.should raise_error(ArgumentError, /:foreground or :background/)
    end

    it "should return a formatted string for just the color code when no args are given" do
      @c.red.should eql("\e[31m")
    end

    it "should return a formatted string with a reset if a full string is supplied" do
      @c.red("this").should eql("\e[31mthis\e[0m")
    end

    it "should recognize when the foreground is being set" do
      @c.red("this", :foreground).should eql("\e[31mthis\e[0m")
    end

    it "should recognize when the background is being set" do
      @c.red("this", :background).should eql("\e[41mthis\e[0m")
    end

    it "should also handle effects" do
      @c.blink("this").should eql("\e[5mthis\e[0m")
    end
    
    it "should fail when effects are handed too many parameters" do
      attempting {
        @c.blink("this", :noarg)
      }.should raise_error(ArgumentError, /max 1/)
    end

    it "should not add an extra reset to the end if decorated more than once" do
      @c.red(@c.blink("this")).should eql("\e[31m\e[5mthis\e[0m")
    end

    it "should be able to format multiple items" do
      @c.multiple("this", [:red, :blink]).should eql("\e[5m\e[31mthis\e[0m")
    end

    it "should keep multiple colors without a reset if the string is nil" do
      @c.multiple(nil, [:red, :blink]).should eql("\e[5m\e[31m")
    end
  end
end
