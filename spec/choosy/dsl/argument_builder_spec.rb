require 'spec_helpers'
require 'choosy/dsl/argument_builder'

module Choosy::DSL
  describe ArgumentBuilder do
    before :each do
      @builder = ArgumentBuilder.new
      @argument = @builder.entity
    end

    describe :required do
      it "should set the argument" do
        @builder.required
        @argument.required?.should be(true)
      end

      it "should set the argument on non-nil/non-true" do
        @builder.required 1
        @argument.required?.should be(false)
      end

      it "should set the argument on false" do
        @builder.required false
        @argument.required?.should be(false)
      end
    end#required

    describe :only do
      it "should require at least one argument" do
        attempting {
          @builder.only
        }.should raise_error(Choosy::ConfigurationError, /'only'/)
      end

      it "should set the allowable_values for an option" do
        @builder.only :this, :that, :other
        @argument.allowable_values.should eql([:this, :that, :other])
      end

      it "should cast to a symbol if not already set" do
        @builder.only :this, :that, :other
        @argument.cast_to.should eql(:symbol)
      end
    end#only

    describe :metaname do
      it "should be able to set the name of the metaname" do
        @builder.metaname 'PARAM'
        @argument.metaname.should eql('PARAM')
      end

      it "should set the arity on STD+ to 1+" do
        @builder.metaname 'STD+'
        @argument.arity.should eql(1..1000)
      end

      it "should set the arity on STD to 1" do
        @builder.metaname 'STD'
        @argument.arity.should eql(1..1)
      end
    end#metaname

    describe :count do
      describe "when welformed" do
        it "should set :at_least the right arity" do
          @builder.count :at_least => 32
          @argument.arity.should eql(32..1000)
        end

        it "should set :at_most the right arity" do
          @builder.count :at_most => 31
          @argument.arity.should eql(1..31)
        end

        it "should set :once to the right arity" do
          @builder.count :once
          @argument.arity.should eql(1..1)
        end

        it "should set :zero to the right arity" do
          @builder.count :zero
          @argument.arity.should eql(0..0)
        end

        it "should set :none to the right arity" do
          @builder.count :none
          @argument.arity.should eql(0..0)
        end

        it "should set a number exactly" do
          @builder.count 3
          @argument.arity.should eql(3..3)
        end

        it "should allow for a range" do
          @builder.count 1..2
          @argument.arity.should eql(1..2)
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

        it "should fail when the :at_least is greater than :at_most" do
          attempting {
            @builder.count :at_least => 3, :at_most => 2
          }.should raise_error(Choosy::ConfigurationError, /lower bound/)
        end
      end
    end#count

    describe :cast do
      it "should allow symbol casts" do
        @builder.cast :int
        @argument.cast_to.should eql(:integer)
      end
  
      class CustomConverter
        def convert(value)
        end
      end

      it "should allow for custom conversions" do
        conv = CustomConverter.new
        @builder.cast conv
        @argument.cast_to.should be(conv)
      end

      it "should fail if it doesn't know about a Type" do
        attempting {
          @builder.cast Choosy::Error
        }.should raise_error(Choosy::ConfigurationError, /Unknown conversion/)
      end

      it "should fail if it doesn't know about a symbol" do
        attempting {
          @builder.cast :unknown_type
        }.should raise_error(Choosy::ConfigurationError, /Unknown conversion/)
      end
    end#cast

    describe :die do
      it "should fail with a specific error" do
        attempting {
          @builder.die("Malformed argument")
        }.should raise_error(Choosy::ValidationError, /argument error: Malformed/)
      end
    end

    describe :validate do
      it "should save the context of the validation in a Proc to call later" do
        @builder.validate do
          puts "Hi!"
        end
        @argument.validation_step.should be_a(Proc)
      end
      
      it "should have access to the larger context when called" do
        value = nil
        @builder.validate do
          value = 'here'
        end
        @argument.validation_step.call
        value.should eql('here')
      end
    end#validate
  end
end

