module Choosy
  describe Option do
    before :each do
      @option = Option.new(:option)
    end

    describe :negated do
      it "should format the long name correctly" do
        @option.long_flag = "--long"
        @option.negation = 'no'
        @option.negated.should eql("--no-long")
      end
    end

    describe :finalize! do
      it "should set the arity if not already set" do
        @option.short_flag = '-s'
        @option.finalize!
        @option.arity.should eql(0..0)
      end

      it "should set the cast to :string on regular arguments" do
        @option.single!
        @option.finalize!
        @option.cast_to.should eql(:string)
      end

      it "should set the cast to :boolean on single flags" do
        @option.finalize!
        @option.cast_to.should eql(:boolean)
      end

      it "should fail when both boolean and restricted" do
        @option.short_flag = '-s'
        @option.allowable_values = [:a, :b]
        attempting{
          @option.finalize!
        }.should raise_error(Choosy::ConfigurationError, /boolean and restricted/)
      end

      it "should fail when the argument is negated and not boolean" do
        @option.long_flag = '--long'
        @option.negation = 'un'
        @option.single!
        attempting {
          @option.finalize!
        }.should raise_error(Choosy::ConfigurationError, /negate a non-boolean option/)
      end

      it "should fail when there is no long boolean option name to negate" do
        @option.short_flag = '-s'
        @option.negation = 'un'
        attempting {
          @option.finalize!
        }.should raise_error(Choosy::ConfigurationError, /long flag is required for negation/)
      end

      it "should set the default value for booleans if not already set" do
        @option.short_flag = '-s'
        @option.finalize!
        @option.default_value.should be(false)
      end
    end#finalize!
  end
end
