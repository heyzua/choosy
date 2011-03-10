require 'spec_helpers'
require 'choosy/argument'

module Choosy
  describe Argument do
    before :each do
      @argument = Argument.new
    end

    describe :restricted? do
      it "should be false when there are no allowable_values" do
        @argument.restricted?.should be(false)
      end

      it "should be true when there are allowable_values" do
        @argument.allowable_values = [:a]
        @argument.restricted?.should be(true)
      end
    end

    describe :finalize! do
      it "should set the arity if not already set" do
        @argument.finalize!
        @argument.arity.should eql(0..0)
      end
    end#finalize!
  end
end
