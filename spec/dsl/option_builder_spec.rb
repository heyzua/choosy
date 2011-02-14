require 'spec_helpers'
require 'choosy'

module Choosy::DSL
  describe OptionBuilder do
    before :each do
      @option = Choosy::Option.new(:stub)
      @builder = OptionBuilder.new(@option)
    end

    describe :short do
      it "should set the option" do
        @builder.short '-s'
        @option.short_flag.should eql('-s')
      end

      describe "and the arity" do
        it "should not be set without a parameter" do
          @builder.short '-s'
          @option.short_flag.should eql('-s')
          @option.arity.should be(nil)
        end

        it "should be set on STD+ parameter" do
          @builder.short '-s', 'STD+'
          @option.arity.should eql(1..1000)
        end

        it "should be set on STD? parameter" do
          @builder.short '-s', 'STD?'
          @option.arity.should eql(0..1)
        end
      
        it "should set single arity on STD parameter" do
          @builder.short '-s', 'STD'
          @option.arity.should eql(1..1)
        end
      end

      describe "and the flag parameter" do
        it "on STD parameters" do
          @builder.short '-s', 'STD'
          @option.flag_parameter.should eql('STD')
        end

        it "on STD+ parameters" do
          @builder.short '-s', 'STD+'
          @option.flag_parameter.should eql('STD+')
        end

        it "on STD? parameters" do
          @builder.short '-s', 'STD?'
          @option.flag_parameter.should eql('STD?')
        end
      end
    end#short

    describe :long do
      it "should set the flag correctly" do
        @builder.long '--short'
        @option.long_flag.should eql('--short')
      end

      describe "while setting arity" do
        it "should not set arity on empty" do
          @builder.long '--short'
          @option.arity.should be(nil)
        end

        it "should set the arity on STD to 1" do
          @builder.long '--short', 'STD'
          @option.arity.should eql(1..1)
        end

        it "should set the arity on STD? to 0-1" do
          @builder.long '--short', 'STD?'
          @option.arity.should eql(0..1)
        end

        it "should set the arity on STD+ to 1+" do
          @builder.long '--short', 'STD+'
          @option.arity.should eql(1..1000)
        end
      end#arity

      describe "and the flag parameter" do
        it "on STD parameters" do
          @builder.long '-s', 'STD'
          @option.flag_parameter.should eql('STD')
        end

        it "on STD+ parameters" do
          @builder.long '-s', 'STD+'
          @option.flag_parameter.should eql('STD+')
        end

        it "on STD? parameters" do
          @builder.long '-s', 'STD?'
          @option.flag_parameter.should eql('STD?')
        end
      end
    end#long

    describe :desc do
      it "should set the option correctly" do
        @builder.desc "This is an option"
        @option.description.should =~ /^This/
      end
    end#desc

    describe :default do
      it "should set the option" do
        @builder.default :clear
        @option.default_value.should eql(:clear)
      end
    end#default

    describe :required do
      it "should set the option" do
        @builder.required
        @option.required?.should be(true)
      end
    end#required

    describe :count do
      describe "when welformed" do
        it "should set :at_least the right arity" do
          @builder.count :at_least => 32
          @option.arity.should eql(32..1000)
        end

        it "should set :at_most the right arity" do
          @builder.count :at_most => 31
          @option.arity.should eql(1..31)
        end

        it "should set :once the right arity" do
          @builder.count :once
          @option.arity.should eql(1..1)
        end

        it "should set :zero te right arity" do
          @builder.count :zero
          @option.arity.should eql(0..0)
        end

        it "should set a number exactly" do
          @builder.count 3
          @option.arity.should eql(3..3)
        end
      end

      describe "when malformed" do
        it "should fail when the :exactly isn't a number" do
          attempting {
            @builder.count :exactly => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :at_most isn't a number" do
          attempting {
            @builder.count :at_most => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :at_least isn't a number" do
          attempting {
            @builder.count :at_least => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :count isn't a number" do
          attempting {
            @builder.count 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end
      end
    end#count

    describe :fail do
      it "should format the error message with both flags" do
        @builder.short '-k'
        @builder.long '--keep', 'KEEP'
        attempting {
          @builder.fail "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /-k\/--keep KEEP: Didn't keep anything/)
      end

      it "should set the format of the error with the short flag" do
        @builder.short '-k'
        attempting {
          @builder.fail "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /-k: Didn't keep anything/)
      end

      it "should set the format of the long flag alone" do
        @builder.long '--keep'
        attempting {
          @builder.fail "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /--keep: Didn't keep anything/)
      end

      it "should alse set the pragram name in the error message"
    end

    describe :validate do
      it "should save theh context of the validation in a Proc to call later"
      it "should allow for formatted failures"
      it "should have access to the larger context when called"
    end
  end
end
